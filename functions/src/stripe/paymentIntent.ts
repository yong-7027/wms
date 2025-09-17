import {Request, Response} from "express";
import Stripe from "stripe";
import "dotenv/config";
import * as admin from "firebase-admin";

const stripeSecret = process.env.STRIPE_SECRET_KEY;
if (!stripeSecret) throw new Error("STRIPE_SECRET not defined");

const stripe = new Stripe(stripeSecret, {apiVersion: "2024-06-20" as any});

export const createPaymentIntent = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    // 1. 解析 Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({error: "Unauthorized: Missing or invalid token"});
    }

    const idToken = authHeader.split("Bearer ")[1];

    // 2. 验证 token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // 3. 获取请求体
    const {amount, currency, planId} = req.body;

    // 4. 创建或获取 customer
    const customers = await stripe.customers.list({
      limit: 1,
      email: decodedToken.email,
    });

    let customer: Stripe.Customer;
    if (customers.data.length > 0) {
      customer = customers.data[0];
    } else {
      customer = await stripe.customers.create({
        metadata: {uid, planId},
        email: decodedToken.email,
      });
    }

    // 5. 创建 PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      customer: customer.id,
      metadata: {planId, uid},
      automatic_payment_methods: {enabled: true},
    });

    let ephemeralKey: Stripe.EphemeralKey | undefined;
    if (customer) {
      ephemeralKey = await stripe.ephemeralKeys.create(
        {customer: customer.id},
        {apiVersion: "2024-06-20"}
      );
    }

    return res.json({
      id: paymentIntent.id,
      client_secret: paymentIntent.client_secret,
      customer_id: customer.id,
      ephemeral_key: ephemeralKey ? ephemeralKey.secret : null,
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error creating payment intent:", error);
    return res.status(500).json({
      error: "Failed to create payment intent",
      details: errorMessage,
    });
  }
};
