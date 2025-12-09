import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/providers/task_provider.dart';
import 'package:reminder_app/services/ai_reminder_service.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

enum TaskType { standard, safetyCritical }

class AddTaskScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onTaskAdded;
  const AddTaskScreen({super.key, this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const platform = MethodChannel('com.example.reminder_app/alarm');

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _voiceInputController = TextEditingController();
  final AIReminderService _aiService = AIReminderService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isListening = false;
  bool _isAIParsing = false;
  bool _isPhotoProofRequired = false;
  File? _capturedImage;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TaskType _selectedTaskType = TaskType.standard;
  final Map<String, bool> _assignees = {
    'Hazrat': false,
    'Azy': false,
    'Everyone': false,
  };

  @override
  void dispose() {
    _taskController.dispose();
    _voiceInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to pick image',
        icon: Icons.error_outline,
      );
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    // TODO: Implement actual speech-to-text here
    if (_isListening) {
      // Simulate voice input after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (_isListening && mounted) {
          setState(() {
            _voiceInputController.text = "Pick up groceries";
            _isListening = false;
          });
          _handleVoiceInputSubmit(_voiceInputController.text);
        }
      });
    }
  }

  Future<void> _handleVoiceInputSubmit(String value) async {
    print('🔵 _handleVoiceInputSubmit called with: "$value"');

    if (value.trim().isEmpty) {
      print('🔴 Empty input, returning');
      return;
    }

    setState(() => _isAIParsing = true);
    print('🔵 Starting AI parsing...');

    try {
      final result = await _aiService.parseReminder(value.trim());
      print('🔵 AI parse result: $result');

      if (result != null && mounted) {
        // Set title
        _taskController.text = result.title;

        // Set time if parsed
        if (result.time != null) {
          _selectedDate = result.time!;
          _selectedTime = TimeOfDay.fromDateTime(result.time!);
        }

        // Set assignee if parsed (case-insensitive matching)
        if (result.assignee != null) {
          final assigneeLower = result.assignee!.toLowerCase();

          // Find matching assignee (case-insensitive)
          String? matchedAssignee;
          for (final key in _assignees.keys) {
            if (key.toLowerCase() == assigneeLower) {
              matchedAssignee = key;
              break;
            }
          }

          if (matchedAssignee != null) {
            _assignees.updateAll((key, value) => false);
            _assignees[matchedAssignee] = true;
          } else if (assigneeLower == 'everyone' || assigneeLower == 'all') {
            _assignees.updateAll((key, value) => true);
          } else {
            // If no match found, assign to Everyone by default
            _assignees.updateAll((key, value) => true);
          }
        } else {
          // No assignee specified, assign to Everyone by default
          _assignees.updateAll((key, value) => true);
        }

        setState(() {});
        _voiceInputController.clear();

        CustomSnackbar.show(
          title: 'AI Parsed',
          message: result.title,
          icon: Icons.auto_awesome,
        );

        // Directly add the task after successful AI parsing
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _addTask();
        }
      } else {
        // Fallback: just use the text as title
        setState(() {
          _taskController.text = value.trim();
        });
        _voiceInputController.clear();

        CustomSnackbar.show(
          title: 'Fallback',
          message: 'Could not parse with AI, using raw text',
          icon: Icons.text_fields,
        );
      }
    } catch (e) {
      print('AI parsing error: $e');
      setState(() {
        _taskController.text = value.trim();
      });
      _voiceInputController.clear();
    } finally {
      if (mounted) {
        setState(() => _isAIParsing = false);
      }
    }
  }

  Future<void> scheduleNativeAlarm(
    DateTime dateTime,
    String title,
    List<String> assignees,
  ) async {
    try {
      final int alarmId = dateTime.millisecondsSinceEpoch ~/ 1000;
      final int timeInMillis = dateTime.millisecondsSinceEpoch;
      final String body = 'Assigned to: ${assignees.join(', ')}';

      await platform.invokeMethod('scheduleAlarm', {
        'time': timeInMillis,
        'id': alarmId,
        'title': title,
        'body': body,
      });

      debugPrint('Alarm scheduled for: $dateTime');
    } on PlatformException catch (e) {
      debugPrint('Failed to schedule alarm: ${e.message}');
    }
  }

  void _handleTaskTypeToggle(int index) {
    TaskType newType = index == 0 ? TaskType.standard : TaskType.safetyCritical;
    setState(() {
      _selectedTaskType = newType;
      _isPhotoProofRequired = newType == TaskType.safetyCritical;
    });
  }

  void _handleAssigneeToggle(String assignee) {
    setState(() {
      if (assignee == 'Everyone') {
        bool isEveryone = _assignees['Everyone']!;
        _assignees['Hazrat'] = !isEveryone;
        _assignees['Azy'] = !isEveryone;
        _assignees['Everyone'] = !isEveryone;
      } else {
        _assignees[assignee] = !_assignees[assignee]!;
        _assignees['Everyone'] = false;
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(data: ThemeData.light(), child: child!);
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addTask() async {
    if (_taskController.text.isEmpty) {
      CustomSnackbar.show(
        title: 'Missing Info',
        message: 'Please enter a task description',
        icon: Icons.edit_note,
      );
      return;
    }

    final assigneesList = _assignees.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (assigneesList.isEmpty) {
      CustomSnackbar.show(
        title: 'Missing Info',
        message: 'Please select at least one assignee',
        icon: Icons.person_add,
      );
      return;
    }

    final String reminderType = _selectedTaskType == TaskType.safetyCritical
        ? 'critical'
        : 'urgent';

    final DateTime fullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final formattedDate = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(fullDateTime);

    final newTask = {
      'title': "${_taskController.text.trim()} - $formattedDate",
      'status': reminderType,
      'icon': _selectedTaskType == TaskType.safetyCritical
          ? Icons.shield_outlined
          : Icons.checklist_rtl,
      'dueDate': fullDateTime.toIso8601String(),
      'done': false,
      'assignees': assigneesList,
      'taskType': _selectedTaskType.name,
      'photoProofRequired': _isPhotoProofRequired,
    };

    await scheduleNativeAlarm(
      fullDateTime,
      _taskController.text.trim(),
      assigneesList,
    );

    CustomSnackbar.show(
      title: 'Task Added',
      message: 'Assigned to: ${assigneesList.join(", ")}',
      icon: Icons.check_circle_outline,
    );
    _taskController.clear();

    // if (widget.onTaskAdded != null) {
    //   widget.onTaskAdded!(newTask);
    // }
    context.read<TaskProvider>().addTask(newTask);
  }

  @override
  Widget build(BuildContext context) {
    final isSafetyCritical = _selectedTaskType == TaskType.safetyCritical;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Task Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Input
                            TextField(
                              controller: _taskController,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: "What needs to be done?",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Date & Time Row
                            Row(
                              children: [
                                Expanded(child: _buildDateButton()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTimeButton()),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Assignees
                            _buildAssignees(),

                            const SizedBox(height: 16),

                            // Task Type Toggle
                            _buildTaskType(isSafetyCritical),
                          ],
                        ),
                      ),
                    ),

                    // Photo Proof Section - Only visible for Critical tasks
                    if (isSafetyCritical) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Photo Proof Required",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (_capturedImage == null)
                              GestureDetector(
                                onTap: _showImageSourceOptions,
                                child: Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 36,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tap to add photo",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _capturedImage!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _removePhoto,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom fixed section: AI Bar + Add Task Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBottomAIBar(),
                  const SizedBox(height: 12),
                  CustomButton.primary(
                    text: "Add Task",
                    onPressed: _addTask,
                    icon: Icons.add_task,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAIBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          // AI sparkle icon
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 5),
          // Text input
          Expanded(
            child: TextField(
              controller: _voiceInputController,
              style: const TextStyle(fontSize: 14),
              enabled: !_isAIParsing,
              decoration: InputDecoration(
                hintText: _isAIParsing
                    ? 'Parsing with AI...'
                    : 'Speak or type to add task...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: _handleVoiceInputSubmit,
            ),
          ),

          // Mic button or loading spinner
          _isAIParsing
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : GestureDetector(
                  // onTap: _toggleListening,
                  onTap: () {
                    CustomSnackbar.show(
                      title: 'Coming Soon',
                      message:
                          'AI voice input is coming soon! Try adding manually',
                      icon: Icons.mic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withOpacity(0.8),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildDateButton() {
    final formattedDate = DateFormat('MMM d').format(_selectedDate);
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton() {
    final formattedTime = _selectedTime.format(context);
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assign to",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _assignees.keys.map((name) {
            final isSelected = _assignees[name]!;
            return GestureDetector(
              onTap: () => _handleAssigneeToggle(name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTaskType(bool isSafetyCritical) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _handleTaskTypeToggle(0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !isSafetyCritical
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: !isSafetyCritical
                      ? AppColors.primaryColor
                      : Colors.grey.shade200,
                  width: !isSafetyCritical ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: !isSafetyCritical
                        ? AppColors.primaryColor
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Standard",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !isSafetyCritical
                          ? AppColors.primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _handleTaskTypeToggle(1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSafetyCritical
                    ? Colors.red.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSafetyCritical
                      ? Colors.red.shade400
                      : Colors.grey.shade200,
                  width: isSafetyCritical ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: isSafetyCritical
                        ? Colors.red.shade600
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Critical",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSafetyCritical
                          ? Colors.red.shade600
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
