import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";

/**
 * Send payment reminder notification
 * @param {string} userId - User ID
 * @param {string} invoiceId - Invoice ID
 * @param {number} amount - Invoice amount
 * @param {string} dueDate - Due date string
 */
export const sendPaymentReminder = async (
  userId: string,
  invoiceId: string,
  amount: number,
  dueDate: string
): Promise<void> => {
  try {
    // 1. Get user's FCM tokens
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    if (!userDoc.exists) {
      functions.logger.error(`User ${userId} does not exist`);
      return;
    }

    const userData = userDoc.data();
    const fcmTokens = userData?.fcmTokens || [];

    if (fcmTokens.length === 0) {
      functions.logger.warn(`User ${userId} has no registered FCM tokens`);
      return;
    }

    // 2. Build notification message
    const message: admin.messaging.MulticastMessage = {
      tokens: fcmTokens,
      notification: {
        title: "💰 Payment Reminder",
        body: `You have an invoice of $${amount} due soon. Due date: ${dueDate}`,
      },
      data: {
        type: "payment_reminder",
        invoiceId,
        amount: amount.toString(),
        dueDate,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "payment_reminders",
        },
      },
    };

    // 3. Send message
    const response = await admin.messaging().sendEachForMulticast(message);
    functions.logger.info(`Successfully sent ${response.successCount} notifications`);

    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          functions.logger.error(`Failed to send to token ${fcmTokens[idx]}:`, resp.error);
        }
      });
    }

    // 4. Record notification history in Firestore
    await admin.firestore().collection("notifications").add({
      userId,
      invoiceId,
      type: "payment_reminder",
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  } catch (error) {
    functions.logger.error("Error sending payment reminder notification:", error);
    throw error;
  }
};

/**
 * Periodically check overdue invoices and send reminders
 */
export const schedulePaymentReminders = onSchedule({
  schedule: "every 24 hours", // 直接在这里指定计划
  timeZone: "Asia/Kuala_Lumpur",
  retryCount: 3, // 添加重试机制
}, async (event) => {
  try {
    const now = new Date();
    const threeDaysLater = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);

    // Find unpaid invoices due within 3 days
    const overdueInvoices = await admin.firestore()
      .collection("invoices")
      .where("status", "==", "unpaid")
      .where("dueDate", "<=", threeDaysLater)
      .where("dueDate", ">", now)
      .get();

    functions.logger.info(`Found ${overdueInvoices.size} upcoming due invoices`);

    for (const invoiceDoc of overdueInvoices.docs) {
      const invoice = invoiceDoc.data();
      const invoiceId = invoiceDoc.id;

      // Check if reminder has been sent today
      const today = new Date().toISOString().split("T")[0];
      const existingReminder = await admin.firestore()
        .collection("notificationLogs")
        .where("invoiceId", "==", invoiceId)
        .where("sentDate", "==", today)
        .get();

      if (existingReminder.empty) {
        await sendPaymentReminder(
          invoice.userId,
          invoiceId,
          invoice.amount,
          invoice.dueDate.toDate().toISOString().split("T")[0] // 格式化日期
        );

        // Record that reminder was sent today
        await admin.firestore().collection("notificationLogs").add({
          invoiceId,
          sentDate: today,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    functions.logger.info("Payment reminder processing completed");
  } catch (error) {
    functions.logger.error("Error processing payment reminders:", error);
    throw error; // 抛出错误以便重试机制工作
  }
});
