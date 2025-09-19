export const generateOverdueEmail = (
  userName: string,
  invoiceId: string,
  amount: number,
  dueDate: string,
  overdueDays: number // 添加逾期天数参数
) => {
  // 根据逾期天数生成不同的主题和内容
  const urgencyLevel = overdueDays > 7 ? "URGENT" : "Reminder";
  const subjectPrefix = overdueDays > 7 ? "🚨 URGENT: " : "Reminder: ";

  return {
    subject: `${subjectPrefix}Invoice #${invoiceId} is ${overdueDays} days overdue - Payment Required`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: ${overdueDays > 7 ? "#ffebee" : "#f8f9fa"}; padding: 20px; text-align: center; }
          .content { padding: 30px; background: #fff; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }
          .button { background: #dc3545; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block; }
          .amount { font-size: 24px; color: #dc3545; font-weight: bold; }
          .urgent { color: #d32f2f; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>${urgencyLevel}: Payment Overdue</h2>
          </div>
          <div class="content">
            <h3>Dear ${userName},</h3>

            ${overdueDays > 7 ? `
            <p class="urgent">⚠️ IMPORTANT: Your invoice is significantly overdue. Immediate payment is required to avoid account suspension.</p>
            ` : ""}

            <p>This is a reminder that your invoice <strong>#${invoiceId}</strong> was due on <strong>${dueDate}</strong> and is now <strong class="urgent">${overdueDays} days overdue</strong>.</p>

            <p style="text-align: center;">
              <span class="amount">$${amount.toFixed(2)}</span>
              <br>
              <span style="color: #666;">${overdueDays} days overdue</span>
            </p>

            <p style="text-align: center;">
              <a href="wms://invoice/${invoiceId}" class="button">Pay Now</a>
            </p>

            <p>If you have already made the payment, please disregard this email. For any questions or payment arrangements, please contact our support team immediately.</p>

            <p>Thank you,<br>Zenova</p>
          </div>
          <div class="footer">
            <p>© ${new Date().getFullYear()} Zenova. All rights reserved.</p>
            <p>This is an automated message, please do not reply to this email.</p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
${urgencyLevel}: PAYMENT OVERDUE

Dear ${userName},

${overdueDays > 7 ? "IMPORTANT: Your invoice is significantly overdue. Immediate payment is required to avoid account suspension.\n\n" : ""}

This is a reminder that your invoice #${invoiceId} was due on ${dueDate} and is now ${overdueDays} days overdue.

Amount Due: $${amount.toFixed(2)}
Overdue: ${overdueDays} days

Pay now: wms://invoice/${invoiceId}

If you have already made the payment, please disregard this email. For any questions or payment arrangements, please contact our support team immediately.

Thank you,
Zenova

© ${new Date().getFullYear()} Zenova. All rights reserved.
This is an automated message, please do not reply to this email.
    `,
  };
};
