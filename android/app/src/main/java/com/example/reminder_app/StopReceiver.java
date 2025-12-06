package com.example.reminder_app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.app.NotificationManager;
import android.media.MediaPlayer;

public class StopReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        // Stop the alarm notification for good

        Intent serviceIntent = new Intent(context, AlarmService.class);
        context.stopService(serviceIntent);

        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        manager.cancel(99);
    }
}
