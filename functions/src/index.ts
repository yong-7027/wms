import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import {createPaymentIntent} from "./stripe/paymentIntent";
import {stripeWebhook} from "./stripe/webhook";
import {verifyPayment} from "./stripe/verifyPayment";
import {createPayPalOrder, capturePayPalOrder, verifyPayPalPayment} from "./paypal/paypalOrder";
import * as admin from "firebase-admin";

import {sendPaymentReminder, schedulePaymentReminders} from "./notifications/reminderNotifications";
import {checkOverdueInvoices} from "./invoices/checkOverdueInvoices";

admin.initializeApp();

const app = express();
app.use(cors({origin: true}));

// 重要：webhook 路由必须在 express.json() 之前
app.post("/stripeWebhook",
  express.raw({type: "application/json"}),
  stripeWebhook
);

// 对其他路由使用 JSON 解析
app.use(express.json());

// Stripe 路由
app.post("/createPaymentIntent", createPaymentIntent);
app.post("/verifyPayment", verifyPayment);

// PayPal 路由
app.post("/createPayPalOrder", createPayPalOrder);
app.post("/capturePayPalOrder", capturePayPalOrder);
app.post("/verifyPayPalPayment", verifyPayPalPayment);

// 通知路由
app.post("/sendPaymentReminder", async (req, res) => {
  try {
    const {userId, invoiceId, amount, dueDate} = req.body;

    // 验证必要参数
    if (!userId || !invoiceId || !amount || !dueDate) {
      return res.status(400).json({
        error: "Missing required parameters: userId, invoiceId, amount, dueDate",
      });
    }

    await sendPaymentReminder(userId, invoiceId, amount, dueDate);

    return res.json({
      success: true,
      message: "Payment reminder sent successfully",
    });
  } catch (error) {
    console.error("Error sending payment reminder:", error);
    return res.status(500).json({
      error: "Failed to send payment reminder",
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

// 测试通知路由
app.post("/testNotification", async (req, res) => {
  try {
    const {userId} = req.body;

    if (!userId) {
      return res.status(400).json({
        error: "Missing userId parameter",
      });
    }

    // 发送测试通知
    await sendPaymentReminder(
      userId,
      "mqNUHuRdE3aCjKZYOouf",
      99.99,
      new Date().toISOString().split("T")[0]
    );

    return res.json({
      success: true,
      message: "Test notification sent successfully",
    });
  } catch (error) {
    console.error("Error sending test notification:", error);
    return res.status(500).json({
      error: "Failed to send test notification",
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

// 根路由
app.get("/", (req, res) => {
  res.json({
    message: "Workshop Management System API",
    timestamp: new Date().toISOString(),
    version: "2.0.0",
    payment_methods: ["stripe", "paypal"],
    routes: {
      stripe: [
        "POST /createPaymentIntent",
        "POST /verifyPayment",
        "POST /stripeWebhook",
      ],
      paypal: [
        "POST /createPayPalOrder",
        "POST /capturePayPalOrder",
        "POST /verifyPayPalPayment",
      ],
      general: [
        "GET /",
        "GET /health",
      ],
    },
  });
});

// 健康检查路由
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    services: {
      firebase: "connected",
      stripe: process.env.STRIPE_SECRET_KEY ? "configured" : "not configured",
      paypal: (process.env.PAYPAL_CLIENT_ID && process.env.PAYPAL_CLIENT_SECRET) ? "configured" : "not configured",
    },
  });
});

export const api = functions.https.onRequest(app);
export {checkOverdueInvoices};
export {schedulePaymentReminders};
