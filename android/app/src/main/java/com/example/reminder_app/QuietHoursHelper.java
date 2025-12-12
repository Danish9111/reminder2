package com.example.reminder_app;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import java.util.Calendar;

/**
 * Helper class for managing Quiet Hours functionality.
 * Checks if current time falls within quiet hours and handles exceptions.
 */
public class QuietHoursHelper {

    private static final String TAG = "QuietHoursHelper";
    private static final String PREFS_NAME = "quiet_hours_prefs";

    // Preference keys
    private static final String KEY_ENABLED = "quiet_hours_enabled";
    private static final String KEY_START_HOUR = "quiet_hours_start_hour";
    private static final String KEY_START_MINUTE = "quiet_hours_start_minute";
    private static final String KEY_END_HOUR = "quiet_hours_end_hour";
    private static final String KEY_END_MINUTE = "quiet_hours_end_minute";
    private static final String KEY_DAYS = "quiet_hours_days"; // comma-separated: "0,1,2,3,4" for Mon-Fri
    private static final String KEY_EXCEPTION_SAFETY_CRITICAL = "quiet_hours_exception_safety_critical";

    /**
     * Check if quiet hours are currently active.
     * Returns true if:
     * 1. Quiet hours are enabled
     * 2. Current day is in the selected days
     * 3. Current time is within the start-end time range
     */
    public static boolean isQuietHoursActive(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);

        // Check if quiet hours are enabled
        boolean enabled = prefs.getBoolean(KEY_ENABLED, false);
        if (!enabled) {
            Log.d(TAG, "Quiet hours disabled");
            return false;
        }

        // Get current time info
        Calendar now = Calendar.getInstance();
        int currentDayOfWeek = now.get(Calendar.DAY_OF_WEEK); // 1=Sunday, 2=Monday, ..., 7=Saturday
        int currentHour = now.get(Calendar.HOUR_OF_DAY);
        int currentMinute = now.get(Calendar.MINUTE);

        // Check if today is a quiet hours day
        // We store days as 0-6 (Mon-Sun), Calendar uses 1-7 (Sun-Sat)
        // Convert: Calendar Sunday(1) -> our 6, Monday(2) -> our 0, etc.
        int ourDayIndex = (currentDayOfWeek == Calendar.SUNDAY) ? 6 : currentDayOfWeek - 2;

        String daysStr = prefs.getString(KEY_DAYS, "");
        if (daysStr.isEmpty()) {
            Log.d(TAG, "No days configured");
            return false;
        }

        String[] days = daysStr.split(",");
        boolean isTodaySelected = false;
        for (String day : days) {
            try {
                if (Integer.parseInt(day.trim()) == ourDayIndex) {
                    isTodaySelected = true;
                    break;
                }
            } catch (NumberFormatException e) {
                // Skip invalid entries
            }
        }

        if (!isTodaySelected) {
            Log.d(TAG, "Today is not a quiet hours day");
            return false;
        }

        // Check time range
        int startHour = prefs.getInt(KEY_START_HOUR, 22);
        int startMinute = prefs.getInt(KEY_START_MINUTE, 0);
        int endHour = prefs.getInt(KEY_END_HOUR, 7);
        int endMinute = prefs.getInt(KEY_END_MINUTE, 0);

        int currentMinutes = currentHour * 60 + currentMinute;
        int startMinutes = startHour * 60 + startMinute;
        int endMinutes = endHour * 60 + endMinute;

        boolean isInQuietHours;

        if (startMinutes <= endMinutes) {
            // Same day range (e.g., 09:00 - 17:00)
            isInQuietHours = currentMinutes >= startMinutes && currentMinutes < endMinutes;
        } else {
            // Overnight range (e.g., 22:00 - 07:00)
            isInQuietHours = currentMinutes >= startMinutes || currentMinutes < endMinutes;
        }

        Log.d(TAG, "Quiet hours active: " + isInQuietHours +
                " (current: " + currentHour + ":" + currentMinute +
                ", range: " + startHour + ":" + startMinute + " - " + endHour + ":" + endMinute + ")");

        return isInQuietHours;
    }

    /**
     * Check if the given task type should bypass quiet hours.
     * Currently only "safetyCritical" tasks can bypass if the exception is enabled.
     */
    public static boolean shouldBypassQuietHours(Context context, String taskType) {
        if (taskType == null) {
            return false;
        }

        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);

        if ("safetyCritical".equals(taskType)) {
            boolean exceptionEnabled = prefs.getBoolean(KEY_EXCEPTION_SAFETY_CRITICAL, true);
            Log.d(TAG, "SafetyCritical task, exception enabled: " + exceptionEnabled);
            return exceptionEnabled;
        }

        return false;
    }

    /**
     * Save quiet hours settings to SharedPreferences.
     */
    public static void saveSettings(
            Context context,
            boolean enabled,
            int startHour,
            int startMinute,
            int endHour,
            int endMinute,
            String days,
            boolean exceptionSafetyCritical) {

        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();

        editor.putBoolean(KEY_ENABLED, enabled);
        editor.putInt(KEY_START_HOUR, startHour);
        editor.putInt(KEY_START_MINUTE, startMinute);
        editor.putInt(KEY_END_HOUR, endHour);
        editor.putInt(KEY_END_MINUTE, endMinute);
        editor.putString(KEY_DAYS, days);
        editor.putBoolean(KEY_EXCEPTION_SAFETY_CRITICAL, exceptionSafetyCritical);

        editor.apply();

        Log.d(TAG, "Quiet hours settings saved: enabled=" + enabled +
                ", time=" + startHour + ":" + startMinute + "-" + endHour + ":" + endMinute +
                ", days=" + days + ", safetyException=" + exceptionSafetyCritical);
    }

    /**
     * Get quiet hours settings from SharedPreferences.
     * Returns a Map with all settings for Flutter to consume.
     */
    public static java.util.HashMap<String, Object> getSettings(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);

        java.util.HashMap<String, Object> settings = new java.util.HashMap<>();
        settings.put("enabled", prefs.getBoolean(KEY_ENABLED, false));
        settings.put("startHour", prefs.getInt(KEY_START_HOUR, 22));
        settings.put("startMinute", prefs.getInt(KEY_START_MINUTE, 0));
        settings.put("endHour", prefs.getInt(KEY_END_HOUR, 7));
        settings.put("endMinute", prefs.getInt(KEY_END_MINUTE, 0));
        settings.put("days", prefs.getString(KEY_DAYS, "0,1,2,3,4"));
        settings.put("exceptionSafetyCritical", prefs.getBoolean(KEY_EXCEPTION_SAFETY_CRITICAL, true));

        return settings;
    }
}
