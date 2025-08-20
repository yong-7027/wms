import {Request, Response} from "express";
import Stripe from "stripe";
import "dotenv/config";
// import * as functions from "firebase-functions";

// const stripeSecret = functions.config().stripe.secret;
const stripeSecret = process.env.STRIPE_SECRET_KEY;
if (!stripeSecret) throw new Error("STRIPE_SECRET not defined");

const stripe = new Stripe(stripeSecret, {apiVersion: "2025-07-30.basil"});

export const createPaymentIntent = async (
  req: Request,
  res: Response
) => {
  try {
    const {amount, currency, planId, userId} = req.body;

    let customer: Stripe.Customer | undefined;
    if (userId) {
      const customers = await stripe.customers.list({limit: 1});
      customer = customers.data.length > 0 ?
        customers.data[0] :
        await stripe.customers.create({
          metadata: {userId, planId},
        });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      customer: customer ? customer.id : undefined,
      metadata: {planId, userId: userId || ""},
      automatic_payment_methods: {enabled: true},
    });

    let ephemeralKey: Stripe.EphemeralKey | undefined;
    if (customer) {
      ephemeralKey = await stripe.ephemeralKeys.create(
        {customer: customer.id},
        {apiVersion: "2025-07-30"}
      );
    }

    res.json({
      id: paymentIntent.id,
      client_secret: paymentIntent.client_secret,
      customer_id: customer ? customer.id : null,
      ephemeral_key: ephemeralKey ? ephemeralKey.secret : null,
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error creating payment intent:", error);
    res.status(500).json({
      error: "Failed to create payment intent",
      details: errorMessage,
    });
  }
};
