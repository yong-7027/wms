import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import {createPaymentIntent} from "./stripe/paymentIntent";
import {stripeWebhook} from "./stripe/webhook";
import {verifyPayment} from "./stripe/verifyPayment";
import {createPayPalOrder, capturePayPalOrder, verifyPayPalPayment} from "./paypal/paypalOrder";
import * as admin from "firebase-admin";

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
