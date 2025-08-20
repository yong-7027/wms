import {Request, Response} from "express";
import Stripe from "stripe";
import "dotenv/config";
// import * as functions from "firebase-functions";

// const stripeSecret = functions.config().stripe.secret;
// const webhookSecret = functions.config().stripe.webhook;
const stripeSecret = process.env.STRIPE_SECRET_KEY;
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

if (!stripeSecret) throw new Error("STRIPE_SECRET not defined");
if (!webhookSecret) throw new Error("STRIPE_WEBHOOK not defined");

const stripe = new Stripe(stripeSecret, {apiVersion: "2025-07-30.basil"});
const endpointSecret = webhookSecret;

export const stripeWebhook = (req: Request, res: Response): void => {
  const sig = req.headers["stripe-signature"] as string;
  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err: unknown) {
    const errorMessage = err instanceof Error ? err.message : "Unknown error";
    console.error("Webhook signature verification failed:", errorMessage);
    res.status(400).send(`Webhook Error: ${errorMessage}`);
    return;
  }

  switch (event.type) {
  case "payment_intent.succeeded": {
    const paymentIntent = event.data.object as Stripe.PaymentIntent;
    console.log("Payment succeeded:", paymentIntent.id);
    break;
  }
  case "payment_intent.payment_failed": {
    const failedPayment = event.data.object as Stripe.PaymentIntent;
    console.log("Payment failed:", failedPayment.id);
    break;
  }
  default:
    console.log(`Unhandled event type ${event.type}`);
  }

  res.json({received: true});
};
