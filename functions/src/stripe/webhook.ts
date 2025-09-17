import {Request, Response} from "express";
import Stripe from "stripe";
import "dotenv/config";
import * as admin from "firebase-admin";

const stripeSecret = process.env.STRIPE_SECRET_KEY;
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

if (!stripeSecret) throw new Error("STRIPE_SECRET not defined");
if (!webhookSecret) throw new Error("STRIPE_WEBHOOK not defined");

const stripe = new Stripe(stripeSecret, {apiVersion: "2024-06-20" as any});

export const stripeWebhook = async (req: Request, res: Response): Promise<void> => {
  console.log("Webhook received"); // 添加日志
  console.log("Headers:", req.headers); // 打印请求头
  console.log("Body type:", typeof req.body); // 打印 body 类型

  const sig = req.headers["stripe-signature"] as string;

  if (!sig) {
    console.error("Missing stripe-signature header");
    res.status(400).send("Missing stripe-signature header");
    return;
  }

  let event: Stripe.Event;

  try {
    // 确保 req.body 是 Buffer 类型
    const body = req.body instanceof Buffer ? req.body : Buffer.from(req.body);
    event = stripe.webhooks.constructEvent(body, sig, webhookSecret);
    console.log("Webhook event verified successfully:", event.type);
  } catch (err: unknown) {
    const errorMessage = err instanceof Error ? err.message : "Unknown error";
    console.error("Webhook signature verification failed:", errorMessage);
    res.status(400).send(`Webhook Error: ${errorMessage}`);
    return;
  }

  try {
    switch (event.type) {
    case "payment_intent.succeeded": {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      console.log("Payment succeeded:", paymentIntent.id);

      // 在这里处理支付成功的逻辑
      await handlePaymentSuccess(paymentIntent);
      break;
    }

    case "payment_intent.payment_failed": {
      const failedPayment = event.data.object as Stripe.PaymentIntent;
      console.log("Payment failed:", failedPayment.id);

      // 在这里处理支付失败的逻辑
      await handlePaymentFailure(failedPayment);
      break;
    }

    case "payment_intent.canceled": {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      console.log("Payment canceled:", paymentIntent.id);
      break;
    }

    default:
      console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({received: true});
  } catch (error) {
    console.error("Error processing webhook:", error);
    res.status(500).json({error: "Internal server error"});
  }
};

// 处理支付成功
async function handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
  try {
    const {uid, planId} = paymentIntent.metadata;

    if (!uid || !planId) {
      console.error("Missing metadata in payment intent:", paymentIntent.id);
      return;
    }

    // 更新用户订阅状态到 Firestore
    const db = admin.firestore();

    // 创建支付记录
    const paymentRecord = {
      paymentIntentId: paymentIntent.id,
      amount: paymentIntent.amount / 100, // 转换回原始金额
      currency: paymentIntent.currency,
      planId: planId,
      userId: uid,
      status: "completed",
      paymentMethod: "stripe",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      stripeCustomerId: paymentIntent.customer as string,
    };

    // 保存支付记录
    await db.collection("payments").doc(paymentIntent.id).set(paymentRecord);

    // 更新用户订阅
    const subscriptionData = {
      planId: planId,
      status: "active",
      startDate: admin.firestore.FieldValue.serverTimestamp(),
      paymentIntentId: paymentIntent.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection("users").doc(uid).collection("subscriptions").doc(planId).set(subscriptionData);

    console.log(`Successfully processed payment for user ${uid}, plan ${planId}`);
  } catch (error) {
    console.error("Error handling payment success:", error);
  }
}

// 处理支付失败
async function handlePaymentFailure(paymentIntent: Stripe.PaymentIntent) {
  try {
    const {uid, planId} = paymentIntent.metadata;

    if (!uid || !planId) {
      console.error("Missing metadata in failed payment intent:", paymentIntent.id);
      return;
    }

    // 记录支付失败
    const db = admin.firestore();
    const failureRecord = {
      paymentIntentId: paymentIntent.id,
      amount: paymentIntent.amount / 100,
      currency: paymentIntent.currency,
      planId: planId,
      userId: uid,
      status: "failed",
      paymentMethod: "stripe",
      failureReason: paymentIntent.last_payment_error?.message || "Unknown error",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection("payment_failures").doc(paymentIntent.id).set(failureRecord);

    console.log(`Recorded payment failure for user ${uid}, plan ${planId}`);
  } catch (error) {
    console.error("Error handling payment failure:", error);
  }
}
