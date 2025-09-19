import * as nodemailer from "nodemailer";
import * as functions from "firebase-functions";

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export const createTransporter = () => {
  const email = process.env.GMAIL_EMAIL;
  const password = process.env.GMAIL_PASSWORD;

  if (!email || !password) {
    throw new Error("Gmail configuration not found");
  }

  // 修正：使用 createTransport 而不是 createTransporter
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: email,
      pass: password,
    },
  });
};

export const sendEmail = async (options: EmailOptions): Promise<void> => {
  try {
    const transporter = createTransporter();
    const from = `"Workshop Management" <${functions.config().gmail.email}>`;

    const mailOptions = {
      from,
      to: options.to,
      subject: options.subject,
      html: options.html,
      text: options.text || options.html.replace(/<[^>]*>/g, ""),
    };

    const result = await transporter.sendMail(mailOptions);
    console.log("Email sent successfully:", result.messageId);
  } catch (error) {
    console.error("Error sending email:", error);
    throw error;
  }
};
