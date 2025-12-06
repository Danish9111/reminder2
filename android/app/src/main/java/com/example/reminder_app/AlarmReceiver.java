package com.example.reminder_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.media.AudioAttributes;
import android.net.Uri;
import android.util.Log;

public class AlarmReceiver extends BroadcastReceiver {

    private static final String CHANNEL_ID = "alarm_channel_v7";

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.e("AlarmReceiver", "onReceive triggered");

        String title = intent.getStringExtra("title");
        String body = intent.getStringExtra("body");

        // Start the alarm service
        Intent serviceIntent = new Intent(context, AlarmService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startService(serviceIntent);
            Log.e("AlarmReceiver", "Foreground service started");
        } else {
            context.startService(serviceIntent);
            Log.e("AlarmReceiver", "Service started");
        }

        // Create notification channel (Oreo+)
        // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // NotificationChannel channel = new NotificationChannel(
        // CHANNEL_ID,
        // "Alarm Notifications",
        // NotificationManager.IMPORTANCE_HIGH
        // );
        // channel.setDescription("Alarm notifications");
        // channel.enableVibration(true);
        // // Don't set a sound here to avoid overriding your MediaPlayer
        // NotificationManager manager =
        // context.getSystemService(NotificationManager.class);
        // manager.createNotificationChannel(channel);
        // }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Uri alarmSound = Uri.parse("android.resource://" + context.getPackageName() + "/raw/second_alarm");

            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Alarm Notifications",
                    NotificationManager.IMPORTANCE_HIGH);
            channel.setDescription("Alarm notifications");
            channel.enableVibration(true);
            channel.setSound(alarmSound, new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build());

            NotificationManager manager = context.getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }

        // App open intent
        Intent openIntent = new Intent(context, MainActivity.class);
        openIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(
                context, 0, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        // Snooze action (example)
        Intent snoozeIntent = new Intent(context, SnoozeReceiver.class);
        PendingIntent snoozePending = PendingIntent.getBroadcast(
                context, 1, snoozeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        // Stop action
        Intent stopIntent = new Intent(context, StopReceiver.class);
        PendingIntent stopPending = PendingIntent.getBroadcast(
                context, 2, stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        // Build notification
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                // .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setAutoCancel(false)
                .setVibrate(new long[] { 0, 500, 1000, 500 })
                .addAction(0, "SNOOZE", snoozePending)
                .addAction(0, "STOP", stopPending);

        NotificationManagerCompat manager = NotificationManagerCompat.from(context);
        manager.notify(99, builder.build());
    }
}
