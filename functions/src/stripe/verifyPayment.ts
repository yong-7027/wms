import {Request, Response} from "express";
import Stripe from "stripe";
import "dotenv/config";
import * as admin from "firebase-admin";

const stripeSecret = process.env.STRIPE_SECRET_KEY;
if (!stripeSecret) throw new Error("STRIPE_SECRET not defined");

const stripe = new Stripe(stripeSecret, {apiVersion: "2024-06-20" as any});

export const verifyPayment = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    // 1. 验证用户身份
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({error: "Unauthorized: Missing or invalid token"});
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // 2. 获取请求参数
    const {paymentIntentId} = req.body;

    if (!paymentIntentId) {
      return res.status(400).json({error: "Missing paymentIntentId"});
    }

    console.log(`Verifying payment for user ${uid}, PaymentIntent: ${paymentIntentId}`);

    // 3. 从 Stripe 获取 PaymentIntent 状态
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    console.log(`PaymentIntent status: ${paymentIntent.status}`);

    // 4. 检查 PaymentIntent 是否属于当前用户
    if (paymentIntent.metadata.uid !== uid) {
      return res.status(403).json({error: "Forbidden: PaymentIntent does not belong to user"});
    }

    // 5. 检查我们的数据库中是否已经处理过这个支付
    const db = admin.firestore();
    const paymentDoc = await db.collection("payments").doc(paymentIntentId).get();

    let databaseStatus = null;
    if (paymentDoc.exists) {
      const paymentData = paymentDoc.data();
      databaseStatus = paymentData?.status;
      console.log(`Database status: ${databaseStatus}`);
    }

    // 6. 返回支付状态信息
    return res.json({
      paymentIntentId: paymentIntent.id,
      status: paymentIntent.status,
      databaseStatus: databaseStatus,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
      processed: paymentDoc.exists,
      webhookProcessed: databaseStatus === "completed",
      clientSecret: paymentIntent.client_secret, // 如果需要重新确认支付
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error verifying payment:", error);

    // 如果是 Stripe 错误，提供更详细的信息
    if (error instanceof Stripe.errors.StripeError) {
      return res.status(400).json({
        error: "Stripe error",
        details: errorMessage,
        type: error.type,
      });
    }

    return res.status(500).json({
      error: "Failed to verify payment",
      details: errorMessage,
    });
  }
};
