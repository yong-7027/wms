class FirebaseFieldNames {
  FirebaseFieldNames._();

  // Common Fields
  static const String status = "status";
  static const String createdAt = "createdAt";

  // Appointment Fields
  static const String appointmentId = "appointmentId";
  static const String serviceTypes = "serviceTypes";
  static const String scheduledAt = "scheduledAt";
  static const String totalPrice = "totalPrice";
  static const String vehicleInfo = "vehicleInfo";
  static const String completedAt = "completedAt";
  static const String hasFeedback = "hasFeedback";
  static const String imagePath = "imagePath";

  // Vehicle Info Fields
  static const String licensePlate = "licensePlate";
  static const String make = "make";
  static const String model = "model";
  static const String year = "year";

  // Service Type Fields
  static const String serviceId = "serviceId";
  static const String serviceName = "serviceName";
  static const String basePrice = "basePrice";
  static const String duration = "duration"; // 服务时长（分钟）
  static const String category = "category"; // 服务时长（分钟）

  // Payment Transaction Fields
  static const String transactionId = "transactionId";
  static const String amount = "amount";
  static const String currency = "currency";
  static const String paymentMethod = "paymentMethod";
  static const String transactionDateTime = "transactionDateTime";

  // Invoice Fields
  static const String invoiceId = "invoiceId";
  static const String userId = "userId";
  static const String issuedAt = "issuedAt";
  static const String dueAt = "dueAt";
  static const String items = "items";

  // Invoice Item Fields
  static const String description = "description";
  static const String type = "type";
  static const String quantity = "quantity";
  static const String unitPrice = "unitPrice";
  static const String itemTotal = "total";

  // Invoice Summary Fields
  static const String subtotal = "subtotal";
  static const String taxRate = "taxRate";
  static const String taxAmount = "taxAmount";
  static const String totalAmount = "totalAmount";
  static const String pdfUrl = "pdfUrl";

  // // Car Service
  // static const String serviceId = 'serviceId';
  // static const String userId = 'userId';
  // static const String serviceType = 'serviceType';
  // static const String price = 'price';
  // static const String scheduledAt = 'scheduledAt';
}