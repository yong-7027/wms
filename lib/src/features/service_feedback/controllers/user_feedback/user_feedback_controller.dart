import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../common/loaders/loaders.dart';
import '../../../../data/repository/service_feedback/service_feedback_repository.dart';
import '../../../../data/repository/service_type/service_type_repository.dart';
import '../../../appointment/models/service_type_model.dart';
import '../../../authentication/controllers/auth_service.dart';
import '../../models/service_feedback_model.dart';

enum SortOption { mostRecent, mostHelpful }
enum FilterOption { all, withMedia, fiveStar, fourStar, threeStar, twoStar, oneStar }

class UserFeedbackController extends GetxController {
  static UserFeedbackController get instance => Get.find();

  final ServiceFeedbackRepository _feedbackRepository = ServiceFeedbackRepository();
  final ServiceTypeRepository _serviceTypeRepository = ServiceTypeRepository();
  // final AuthenticationRepository _authRepository = AuthenticationRepository();
  final AuthService _authService = AuthService();

  // Observables
  final RxList<ServiceFeedbackModel> allFeedbacks = <ServiceFeedbackModel>[].obs;
  final RxList<ServiceFeedbackModel> filteredFeedbacks = <ServiceFeedbackModel>[].obs;
  final RxMap<String, List<ServiceTypeModel>> serviceTypesMap = <String, List<ServiceTypeModel>>{}.obs;
  final RxMap<String, int> reportCounts = <String, int>{}.obs;
  final RxSet<String> userReportedFeedbacks = <String>{}.obs;

  final Rx<SortOption> selectedSort = SortOption.mostRecent.obs;
  final Rx<FilterOption> selectedFilter = FilterOption.all.obs;
  final RxBool isLoading = false.obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalReviews = 0.obs;
  final RxMap<int, int> ratingDistribution = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeedbacks();
    loadUserReports();
  }

  /// Load all feedbacks with real-time updates
  void loadFeedbacks() {
    try {
      isLoading.value = true;

      // Get current user ID (if needed for filtering)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      // final currentUserId = _authService._auth?.uid;

      // Listen to feedback changes in real-time
      _feedbackRepository.getRecentFeedbacks(limit: 100).listen((feedbacks) async {
        allFeedbacks.value = feedbacks;

        // Load service types for each feedback
        await _loadServiceTypesForFeedbacks(feedbacks);

        // Apply current filters and sorting
        _applyFiltersAndSorting();

        // Calculate statistics
        _calculateStatistics();

        isLoading.value = false;
      }, onError: (error) {
        isLoading.value = false;
        TLoaders.errorSnackBar(title: 'Error', message: 'Failed to load reviews: $error');
      });
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to load reviews: $e');
    }
  }

  /// Load service types for feedbacks
  Future<void> _loadServiceTypesForFeedbacks(List<ServiceFeedbackModel> feedbacks) async {
    try {
      final Map<String, List<ServiceTypeModel>> tempServiceTypes = {};

      for (final feedback in feedbacks) {
        if (!tempServiceTypes.containsKey(feedback.appointmentId)) {
          // Get appointment details to fetch service types
          final serviceTypes = await _serviceTypeRepository.getServiceTypesByAppointmentId(feedback.appointmentId);
          tempServiceTypes[feedback.appointmentId] = serviceTypes;
        }
      }

      serviceTypesMap.value = tempServiceTypes;
    } catch (e) {
      print('Error loading service types: $e');
    }
  }

  /// Load user's report history
  void loadUserReports() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Load reported feedbacks from local storage or Firestore
    // This would need to be implemented based on your storage strategy
    // For now, using empty set
    userReportedFeedbacks.value = {};
  }

  /// Apply filters and sorting
  void _applyFiltersAndSorting() {
    List<ServiceFeedbackModel> filtered = List.from(allFeedbacks);

    // Apply filter
    switch (selectedFilter.value) {
      case FilterOption.withMedia:
        filtered = filtered.where((f) => f.mediaFilenames.isNotEmpty).toList();
        break;
      case FilterOption.fiveStar:
        filtered = filtered.where((f) => f.averageRating >= 4.5).toList();
        break;
      case FilterOption.fourStar:
        filtered = filtered.where((f) => f.averageRating >= 3.5 && f.averageRating < 4.5).toList();
        break;
      case FilterOption.threeStar:
        filtered = filtered.where((f) => f.averageRating >= 2.5 && f.averageRating < 3.5).toList();
        break;
      case FilterOption.twoStar:
        filtered = filtered.where((f) => f.averageRating >= 1.5 && f.averageRating < 2.5).toList();
        break;
      case FilterOption.oneStar:
        filtered = filtered.where((f) => f.averageRating < 1.5).toList();
        break;
      case FilterOption.all:
      default:
      // No filter
        break;
    }

    // Apply sorting
    switch (selectedSort.value) {
      case SortOption.mostRecent:
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case SortOption.mostHelpful:
        filtered.sort((a, b) => b.likes.length.compareTo(a.likes.length));
        break;
    }

    filteredFeedbacks.value = filtered;
  }

  /// Calculate statistics
  void _calculateStatistics() {
    if (allFeedbacks.isEmpty) {
      averageRating.value = 0.0;
      totalReviews.value = 0;
      ratingDistribution.clear();
      return;
    }

    totalReviews.value = allFeedbacks.length;

    // Calculate average rating
    double total = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final feedback in allFeedbacks) {
      total += feedback.averageRating;
      int roundedRating = feedback.averageRating.round();
      if (roundedRating < 1) roundedRating = 1;
      if (roundedRating > 5) roundedRating = 5;
      distribution[roundedRating] = (distribution[roundedRating] ?? 0) + 1;
    }

    averageRating.value = total / allFeedbacks.length;
    ratingDistribution.value = distribution;
  }

  /// Update sort option
  void updateSort(SortOption sort) {
    selectedSort.value = sort;
    _applyFiltersAndSorting();
  }

  /// Update filter option
  void updateFilter(FilterOption filter) {
    selectedFilter.value = filter;
    _applyFiltersAndSorting();
  }

  /// Report a feedback
  Future<void> reportFeedback(String feedbackId, String reason) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if user already reported this feedback
      if (userReportedFeedbacks.contains(feedbackId)) {
        TLoaders.warningSnackBar(title: 'Already Reported', message: 'You have already reported this review');
        return;
      }

      // Update report count in Firestore
      await _feedbackRepository.reportFeedback(feedbackId, user.uid, reason);

      // Update local state
      userReportedFeedbacks.add(feedbackId);
      reportCounts[feedbackId] = (reportCounts[feedbackId] ?? 0) + 1;

      TLoaders.successSnackBar(title: 'Success', message: 'Review reported successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to report review: $e');
    }
  }

  /// Toggle like on feedback
  Future<void> toggleLike(String feedbackId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final feedbackIndex = filteredFeedbacks.indexWhere((f) => f.id == feedbackId);
      if (feedbackIndex == -1) return;

      final feedback = filteredFeedbacks[feedbackIndex];
      final isLiked = feedback.likes.contains(user.uid);

      if (isLiked) {
        await _feedbackRepository.removeLike(feedbackId, user.uid);
      } else {
        await _feedbackRepository.addLike(feedbackId, user.uid);
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to update like: $e');
    }
  }

  /// Get service types for a feedback
  List<ServiceTypeModel> getServiceTypesForFeedback(String appointmentId) {
    return serviceTypesMap[appointmentId] ?? [];
  }

  /// Check if current user can report a feedback
  bool canReportFeedback(String feedbackId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // 检查用户是否已经举报过这个反馈
    final alreadyReported = userReportedFeedbacks.contains(feedbackId);

    // 可以举报的条件：用户已登录且未举报过该反馈
    return !alreadyReported;
  }

  /// Check if feedback belongs to current user
  bool isFeedbackFromCurrentUser(ServiceFeedbackModel feedback) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    // 根据你的实际数据结构进行调整：
    // 方式1: 如果 feedback 有 creatorId 字段
    // return feedback.creatorId == user.uid;

    // 方式2: 如果 feedback 关联的 appointment 有 userId 字段
    // return feedback.appointmentUserId == user.uid;

    // 方式3: 如果通过其他方式关联
    // 这里需要根据你的实际数据结构来实现

    // 暂时返回 false（根据你的注释）
    return false;
  }

  @override
  void onClose() {
    super.onClose();
  }
}