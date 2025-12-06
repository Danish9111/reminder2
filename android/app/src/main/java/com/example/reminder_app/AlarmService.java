package com.example.reminder_app;

import android.app.Service;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.IBinder;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import android.util.Log;
import android.media.RingtoneManager;
import android.net.Uri;

public class AlarmService extends Service {

    private MediaPlayer mediaPlayer;
    private static final String CHANNEL_ID = "alarm_service_channel_2";

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Log to verify service start
        Log.e("AlarmService", "Service triggered");

        // Find custom sound in raw folder
        int resId = getResources().getIdentifier("second_alarm", "raw", getPackageName());
        Log.e("AlarmService", "resId = " + resId);

        if (resId != 0) {
            mediaPlayer = MediaPlayer.create(this, resId);
            // Loop the sound

            Log.e("AlarmService", "Sound found! Playing");
        } else {
            Log.e("AlarmService", "Sound not found! Using default.");
            mediaPlayer = MediaPlayer.create(this,
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM));
        }

        mediaPlayer.start();
        mediaPlayer.setLooping(true);

        // Setup foreground notification to prevent service from being killed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Alarm Service",
                    NotificationManager.IMPORTANCE_LOW);
            channel.setDescription("Alarm is running");
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }

            NotificationCompat.Builder notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setContentTitle("Alarm Running")
                    .setContentText("Your alarm is active")
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setPriority(NotificationCompat.PRIORITY_LOW);

            startForeground(1, notification.build());
        }

        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
        super.onDestroy();
        Log.e("AlarmService", "Service destroyed");
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
