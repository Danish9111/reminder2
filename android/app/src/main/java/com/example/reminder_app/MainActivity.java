package com.example.reminder_app;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "com.example.reminder_app/alarm";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("scheduleAlarm")) {
                                long time = call.argument("time");
                                int id = call.argument("id");
                                String title = call.argument("title");
                                String body = call.argument("body");
                                String taskType = call.argument("taskType");
                                if (taskType == null)
                                    taskType = "standard";

                                scheduleExactAlarm(id, time, title, body, taskType);
                                result.success("Alarm scheduled");
                            } else if (call.method.equals("saveQuietHours")) {
                                boolean enabled = call.argument("enabled");
                                int startHour = call.argument("startHour");
                                int startMinute = call.argument("startMinute");
                                int endHour = call.argument("endHour");
                                int endMinute = call.argument("endMinute");
                                String days = call.argument("days");
                                boolean exceptionSafetyCritical = call.argument("exceptionSafetyCritical");

                                QuietHoursHelper.saveSettings(
                                        this,
                                        enabled,
                                        startHour,
                                        startMinute,
                                        endHour,
                                        endMinute,
                                        days,
                                        exceptionSafetyCritical);
                                result.success("Quiet hours saved");
                            } else if (call.method.equals("getQuietHours")) {
                                java.util.HashMap<String, Object> settings = QuietHoursHelper.getSettings(this);
                                result.success(settings);
                            } else {
                                result.notImplemented();
                            }
                        });
    }

    private void scheduleExactAlarm(int id, long timeMillis, String title, String body, String taskType) {
        AlarmManager alarmManager = (AlarmManager) getSystemService(ALARM_SERVICE);
        Intent intent = new Intent(this, AlarmReceiver.class);
        intent.putExtra("title", title);
        intent.putExtra("body", body);
        intent.putExtra("taskType", taskType);

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                this,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT
                        | (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ? PendingIntent.FLAG_MUTABLE : 0));

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent);
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent);
        }
    }
}
