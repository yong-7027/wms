import {Request, Response} from "express";
import * as admin from "firebase-admin";

const PAYPAL_CLIENT_ID = process.env.PAYPAL_CLIENT_ID;
const PAYPAL_CLIENT_SECRET = process.env.PAYPAL_CLIENT_SECRET;
const PAYPAL_BASE_URL = "https://api-m.sandbox.paypal.com";

// 获取 PayPal Access Token
async function getPayPalAccessToken(): Promise<string> {
  if (!PAYPAL_CLIENT_ID || !PAYPAL_CLIENT_SECRET) {
    throw new Error("PayPal credentials are missing!");
  }

  const auth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_CLIENT_SECRET}`).toString("base64");

  const response = await fetch(`${PAYPAL_BASE_URL}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${auth}`,
      "Accept": "application/json",
      "Accept-Language": "en_US",
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });

  const data = await response.json();
  return data.access_token;
}

// 创建 PayPal 订单
export const createPayPalOrder = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    // 1. 验证用户身份
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({error: "Unauthorized"});
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // 2. 获取请求数据
    const {amount, currency, invoiceId, description} = req.body;

    if (!amount || !currency || !invoiceId) {
      return res.status(400).json({
        error: "Missing required fields: amount, currency, invoiceId",
      });
    }

    // 3. 获取 PayPal access token
    const accessToken = await getPayPalAccessToken();

    // 4. 创建 PayPal 订单
    const orderData = {
      intent: "CAPTURE",
      purchase_units: [{
        reference_id: invoiceId,
        amount: {
          currency_code: currency.toUpperCase(),
          value: amount.toFixed(2),
        },
        description: `Car Service: ${description}`,
        custom_id: `${uid}_${invoiceId}`,
      }],
      application_context: {
        brand_name: "Workshop Management System",
        locale: "en-US",
        landing_page: "BILLING",
        user_action: "PAY_NOW",
        shipping_preference: "NO_SHIPPING",
        // 使用自定义URL方案进行深度链接
        return_url: `wms://payment/paypal-success?userId=${uid}&invoiceId=${invoiceId}&amount=${amount}&currency=${currency}&description=${encodeURIComponent(description)}`,
        cancel_url: `wms://payment/paypal-cancel?userId=${uid}`,
      },
    };

    const paypalResponse = await fetch(`${PAYPAL_BASE_URL}/v2/checkout/orders`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${accessToken}`,
        "PayPal-Request-Id": `${uid}_${Date.now()}`, // 幂等性
      },
      body: JSON.stringify(orderData),
    });

    const order = await paypalResponse.json();

    if (!paypalResponse.ok) {
      console.error("PayPal order creation failed:", order);
      return res.status(400).json({
        error: "Failed to create PayPal order",
        details: order,
      });
    }

    console.log(`Created PayPal order: ${order.id} for user: ${uid}`);

    return res.json({
      id: order.id,
      status: order.status,
      links: order.links,
      approval_url: order.links.find((link: any) => link.rel === "approve")?.href,
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error creating PayPal order:", error);
    return res.status(500).json({
      error: "Failed to create PayPal order",
      details: errorMessage,
    });
  }
};

// 捕获 PayPal 支付 - 简化版本，主要验证
export const capturePayPalOrder = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    // 验证用户身份
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({error: "Unauthorized"});
    }

    //     const idToken = authHeader.split("Bearer ")[1];
    //     const decodedToken = await admin.auth().verifyIdToken(idToken);
    //     const uid = decodedToken.uid;

    const {orderId} = req.body;

    if (!orderId) {
      return res.status(400).json({error: "Missing orderId"});
    }

    // 获取 access token
    const accessToken = await getPayPalAccessToken();

    // 捕获支付
    const captureResponse = await fetch(`${PAYPAL_BASE_URL}/v2/checkout/orders/${orderId}/capture`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${accessToken}`,
      },
    });

    const captureData = await captureResponse.json();

    if (!captureResponse.ok) {
      console.error("PayPal capture failed:", captureData);
      return res.status(400).json({
        error: "Failed to capture PayPal payment",
        details: captureData,
      });
    }

    console.log(`PayPal payment captured: ${captureData.purchase_units[0]?.payments?.captures[0]?.id}`);

    return res.json({
      orderId,
      captureId: captureData.purchase_units[0]?.payments?.captures[0]?.id,
      status: captureData.status,
      amount: captureData.purchase_units[0]?.payments?.captures[0]?.amount,
      payer: captureData.payer,
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error capturing PayPal order:", error);
    return res.status(500).json({
      error: "Failed to capture PayPal payment",
      details: errorMessage,
    });
  }
};

// 验证 PayPal 支付状态
export const verifyPayPalPayment = async (
  req: Request,
  res: Response
): Promise<Response> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({error: "Unauthorized"});
    }

    //     const idToken = authHeader.split("Bearer ")[1];
    //     const decodedToken = await admin.auth().verifyIdToken(idToken);
    //     const uid = decodedToken.uid;

    const {orderId} = req.body;

    if (!orderId) {
      return res.status(400).json({error: "Missing orderId"});
    }

    // 获取 PayPal 订单状态
    const accessToken = await getPayPalAccessToken();

    const paypalResponse = await fetch(`${PAYPAL_BASE_URL}/v2/checkout/orders/${orderId}`, {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    });

    const paypalOrder = await paypalResponse.json();

    if (!paypalResponse.ok) {
      return res.status(400).json({
        error: "Failed to get PayPal order status",
        details: paypalOrder,
      });
    }

    return res.json({
      orderId,
      status: paypalOrder.status,
      amount: paypalOrder.purchase_units[0]?.amount,
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error verifying PayPal payment:", error);
    return res.status(500).json({
      error: "Failed to verify PayPal payment",
      details: errorMessage,
    });
  }
};
