import https from 'https';
import mongoose from 'mongoose';
import { PushSubscription } from '../models/PushSubscription';
import { logger } from '../utils/logger';

type PushPayload = {
  userId: mongoose.Types.ObjectId | string;
  title: string;
  body: string;
  data?: Record<string, string>;
};

export async function sendPushNotification(payload: PushPayload): Promise<void> {
  const oneSignalAppId = process.env.ONESIGNAL_APP_ID;
  const oneSignalApiKey = process.env.ONESIGNAL_API_KEY;
  if (!oneSignalAppId || !oneSignalApiKey) return;

  const subscriptions = await PushSubscription.find({
    userId: payload.userId,
    provider: 'onesignal',
    isActive: true,
  }).select('deviceToken');

  if (subscriptions.length === 0) return;

  await sendOneSignal({
    appId: oneSignalAppId,
    apiKey: oneSignalApiKey,
    playerIds: subscriptions.map((s) => s.deviceToken),
    title: payload.title,
    body: payload.body,
    data: payload.data,
  });
}

function sendOneSignal(input: {
  appId: string;
  apiKey: string;
  playerIds: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}): Promise<void> {
  const body = JSON.stringify({
    app_id: input.appId,
    include_player_ids: input.playerIds,
    headings: { en: input.title, ar: input.title },
    contents: { en: input.body, ar: input.body },
    data: input.data ?? {},
  });

  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: 'onesignal.com',
        path: '/api/v1/notifications',
        method: 'POST',
        headers: {
          Authorization: `Basic ${input.apiKey}`,
          'Content-Type': 'application/json; charset=utf-8',
          'Content-Length': Buffer.byteLength(body),
        },
      },
      (res) => {
        res.resume();
        res.on('end', () => resolve());
      },
    );

    req.on('error', (error) => {
      logger.warn('Push notification delivery failed', { error });
      resolve();
    });
    req.write(body);
    req.end();
  });
}
