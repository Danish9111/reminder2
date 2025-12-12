import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

class QuietHoursScreen extends StatefulWidget {
  const QuietHoursScreen({super.key});

  @override
  State<QuietHoursScreen> createState() => _QuietHoursScreenState();
}

class _QuietHoursScreenState extends State<QuietHoursScreen> {
  static const platform = MethodChannel('com.example.reminder_app/alarm');
  bool _isSaving = false;
  bool _isLoading = true;

  bool _quietHoursEnabled = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);

  // Days selection (Mon-Sun)
  List<bool> _selectedDays = [true, true, true, true, true, false, false];
  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Exception settings
  bool _allowSafetyCritical = true;
  // bool _allowFamilyEmergency = true;
  // bool _allowMedicationReminders = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final Map<dynamic, dynamic>? settings = await platform.invokeMethod(
        'getQuietHours',
      );

      if (settings != null && mounted) {
        setState(() {
          _quietHoursEnabled = settings['enabled'] ?? false;
          _startTime = TimeOfDay(
            hour: settings['startHour'] ?? 22,
            minute: settings['startMinute'] ?? 0,
          );
          _endTime = TimeOfDay(
            hour: settings['endHour'] ?? 7,
            minute: settings['endMinute'] ?? 0,
          );

          // Parse days string to bool list
          final String daysStr = settings['days'] ?? '0,1,2,3,4';
          _selectedDays = List.generate(7, (_) => false);
          if (daysStr.isNotEmpty) {
            for (String dayIndex in daysStr.split(',')) {
              final int? idx = int.tryParse(dayIndex.trim());
              if (idx != null && idx >= 0 && idx < 7) {
                _selectedDays[idx] = true;
              }
            }
          }

          _allowSafetyCritical = settings['exceptionSafetyCritical'] ?? true;
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to load quiet hours: ${e.message}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _saveQuietHours() async {
    setState(() => _isSaving = true);

    try {
      // Build days string (comma-separated indices)
      final List<int> selectedDayIndices = [];
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) selectedDayIndices.add(i);
      }
      final String daysString = selectedDayIndices.join(',');

      await platform.invokeMethod('saveQuietHours', {
        'enabled': _quietHoursEnabled,
        'startHour': _startTime.hour,
        'startMinute': _startTime.minute,
        'endHour': _endTime.hour,
        'endMinute': _endTime.minute,
        'days': daysString,
        'exceptionSafetyCritical': _allowSafetyCritical,
      });

      CustomSnackbar.show(
        title: 'Saved',
        message: 'Quiet hours settings saved',
        icon: Icons.check_circle_outline,
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to save quiet hours: ${e.message}');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to save settings',
        icon: Icons.error_outline,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey.shade800,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quiet Hours',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveQuietHours,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.1),
                            AppColors.primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pause Reminders',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Silence non-essential reminders during sleep or focus time.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Toggle
                    _buildSectionCard(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Enable Quiet Hours',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          _quietHoursEnabled
                              ? 'Reminders will be silenced during set times'
                              : 'All reminders are active',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        value: _quietHoursEnabled,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _quietHoursEnabled = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time Selection
                    if (_quietHoursEnabled) ...[
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionCard(
                        child: Column(
                          children: [
                            // Start Time
                            _buildTimeSelector(
                              icon: Icons.bedtime_outlined,
                              label: 'Start Time',
                              time: _startTime,
                              onTap: () => _selectTime(context, true),
                            ),
                            Divider(color: Colors.grey.shade200, height: 24),
                            // End Time
                            _buildTimeSelector(
                              icon: Icons.wb_sunny_outlined,
                              label: 'End Time',
                              time: _endTime,
                              onTap: () => _selectTime(context, false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Days Selection
                      const Text(
                        'Repeat On',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(7, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDays[index] =
                                          !_selectedDays[index];
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _selectedDays[index]
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                      boxShadow: _selectedDays[index]
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _dayLabels[index],
                                        style: TextStyle(
                                          color: _selectedDays[index]
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getSelectedDaysText(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Exceptions
                      const Text(
                        'Exceptions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'These reminders will still come through during quiet hours',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSectionCard(
                        child: Column(
                          children: [
                            _buildExceptionToggle(
                              icon: Icons.security,
                              iconColor: Colors.red.shade600,
                              title: 'Safety-Critical Tasks',
                              subtitle:
                                  'Never silence safety-related reminders',
                              value: _allowSafetyCritical,
                              onChanged: (value) {
                                setState(() {
                                  _allowSafetyCritical = value;
                                });
                              },
                            ),
                            // Divider(color: Colors.grey.shade200, height: 1),
                            // _buildExceptionToggle(
                            //   icon: Icons.family_restroom,
                            //   iconColor: Colors.blue.shade600,
                            //   title: 'Family Emergency Alerts',
                            //   subtitle: 'Allow urgent family notifications',
                            //   value: _allowFamilyEmergency,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       _allowFamilyEmergency = value;
                            //     });
                            //   },
                            // ),
                            // Divider(color: Colors.grey.shade200, height: 1),
                            // _buildExceptionToggle(
                            //   icon: Icons.medication,
                            //   iconColor: Colors.green.shade600,
                            //   title: 'Medication Reminders',
                            //   subtitle: 'Never miss important medications',
                            //   value: _allowMedicationReminders,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       _allowMedicationReminders = value;
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTimeSelector({
    required IconData icon,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildExceptionToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _getSelectedDaysText() {
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) {
        selected.add(_dayNames[i]);
      }
    }
    if (selected.isEmpty) return 'No days selected';
    if (selected.length == 7) return 'Every day';
    if (selected.length == 5 && !_selectedDays[5] && !_selectedDays[6]) {
      return 'Weekdays';
    }
    if (selected.length == 2 && _selectedDays[5] && _selectedDays[6]) {
      return 'Weekends';
    }
    return selected.join(', ');
  }
}
