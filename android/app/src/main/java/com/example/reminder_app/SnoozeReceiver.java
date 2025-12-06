package com.example.reminder_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.app.NotificationManager;
import android.app.AlarmManager;
import android.app.PendingIntent;

public class SnoozeReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        // Stop the current alarm
        Intent serviceIntent = new Intent(context, AlarmService.class);
        context.stopService(serviceIntent);

        // Cancel current notification
        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        manager.cancel(99);

        // Reschedule alarm after 5 minutes
        long snoozeTime = System.currentTimeMillis() + 1 * 60 * 1000; // 1 minutes
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

        Intent alarmIntent = new Intent(context, AlarmReceiver.class);
        alarmIntent.putExtra("title", "Wake Up!");
        alarmIntent.putExtra("body", "Snoozed Alarm");

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context, 0, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        if (alarmManager != null) {
            alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    snoozeTime,
                    pendingIntent);
        }
    }
}
