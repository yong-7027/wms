import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {sendEmail} from "../utils/emailConfig";
import {generateOverdueEmail} from "../utils/emailTemplates";

export const checkOverdueInvoices = onSchedule({
  schedule: "every 60 minutes",
  timeZone: "Asia/Kuala_Lumpur",
  retryCount: 3,
}, async (event) => {
  try {
    const now = new Date();
    const nowTimestamp = admin.firestore.Timestamp.now();

    // 查找所有逾期发票
    const overdueInvoicesSnapshot = await admin.firestore()
      .collection("invoices")
      .where("status", "in", ["unpaid", "overdue"])
      .where("dueAt", "<", nowTimestamp)
      .get();

    console.log(`Found ${overdueInvoicesSnapshot.size} overdue invoices`);

    for (const doc of overdueInvoicesSnapshot.docs) {
      const invoiceData = doc.data();
      const invoiceId = doc.id;

      // 更新状态为 overdue（如果还不是的话）
      if (invoiceData.status !== "overdue") {
        await doc.ref.update({
          status: "overdue",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Marked invoice ${invoiceId} as overdue`);
      }

      // 计算逾期天数
      const dueDate = invoiceData.dueAt.toDate();
      const overdueDays = Math.floor((now.getTime() - dueDate.getTime()) / (1000 * 60 * 60 * 24));

      // 每3天发送一次邮件（逾期第3、6、9、12...天发送）
      if (overdueDays > 0 && overdueDays % 3 === 0) {
        await sendOverdueEmailReminder(invoiceData, invoiceId, overdueDays);
      }
    }
  } catch (error) {
    console.error("Error in checkOverdueInvoices:", error);
  }
});

async function sendOverdueEmailReminder(
  invoiceData: any,
  invoiceId: string,
  overdueDays: number
): Promise<void> {
  try {
    // 获取用户信息
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(invoiceData.userId)
      .get();

    if (!userDoc.exists) {
      console.error(`User ${invoiceData.userId} not found for invoice ${invoiceId}`);
      return;
    }

    const userData = userDoc.data();
    if (!userData?.email) {
      console.error(`No email found for user ${invoiceData.userId}`);
      return;
    }

    const emailTemplate = generateOverdueEmail(
      userData.displayName || "Customer",
      invoiceId,
      invoiceData.totalAmount,
      invoiceData.dueAt.toDate().toLocaleDateString(),
      overdueDays
    );

    await sendEmail({
      to: userData.email,
      subject: emailTemplate.subject,
      html: emailTemplate.html,
      text: emailTemplate.text,
    });

    console.log(`Overdue email sent for invoice ${invoiceId} (${overdueDays} days overdue)`);
  } catch (emailError) {
    console.error(`Failed to send email for invoice ${invoiceId}:`, emailError);
  }
}
