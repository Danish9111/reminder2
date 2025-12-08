import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/AppColors/AppColors.dart';

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

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  TaskType _selectedTaskType = TaskType.standard;
  final Map<String, bool> _assignees = {
    'Hazrat': false,
    'Azy': false,
    'Everyone': false,
  };
  bool _isPhotoProofRequired = false;

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

  // -----------------------------------------------------
  // 🔥 FULLY UPDATED _addTask() with scheduleNativeAlarm
  // -----------------------------------------------------
  void _addTask() async {
    if (_taskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a task description.")),
      );
      return;
    }

    final assigneesList = _assignees.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (assigneesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one assignee.")),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Task added! Type: ${_selectedTaskType.name}, To: ${assigneesList.join(', ')}",
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    if (widget.onTaskAdded != null) {
      widget.onTaskAdded!(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isSafetyCritical = _selectedTaskType == TaskType.safetyCritical;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputCard(screenWidth, textScale),
              SizedBox(height: screenHeight * 0.02),
              _buildDateTimeSelectors(screenWidth, textScale),
              SizedBox(height: screenHeight * 0.02),
              _buildTaskTypeToggle(isSafetyCritical, screenWidth, textScale),
              SizedBox(height: screenHeight * 0.02),
              _buildMultiAssignCheckboxes(screenWidth, textScale),
              SizedBox(height: screenHeight * 0.02),
              if (_isPhotoProofRequired)
                _buildPhotoProofSection(
                  isSafetyCritical,
                  screenWidth,
                  textScale,
                ),
              if (isSafetyCritical)
                _buildSafetyCriticalNotes(screenWidth, textScale),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildAddTaskButton(
        screenWidth,
        screenHeight,
        textScale,
      ),
    );
  }

  // ----------------------------------------------------------------
  // 💡 BELOW: ALL YOUR ORIGINAL WIDGET BUILDERS (UNCHANGED)
  // ----------------------------------------------------------------

  Widget _buildDateTimeSelectors(double width, double scale) {
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    final formattedTime = _selectedTime.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Due Date & Time",
          style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: width * 0.02),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                icon: Icons.calendar_today,
                label: formattedDate,
                onTap: _selectDate,
                screenWidth: width,
                textScale: scale,
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: _buildDateTimeButton(
                icon: Icons.access_time,
                label: formattedTime,
                onTap: _selectTime,
                screenWidth: width,
                textScale: scale,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double screenWidth,
    required double textScale,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03,
          horizontal: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor),
            SizedBox(width: screenWidth * 0.02),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * textScale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(double width, double scale) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Task Details",
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: width * 0.02),
            TextField(
              controller: _taskController,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "E.g., Empty the dishwasher...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTypeToggle(
    bool isSafetyCritical,
    double width,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Task Type: ",
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              isSafetyCritical ? Icons.security : Icons.check_circle_outline,
              color: isSafetyCritical ? Colors.red : Colors.blue,
            ),
          ],
        ),
        SizedBox(height: width * 0.02),
        ToggleButtons(
          isSelected: [
            _selectedTaskType == TaskType.standard,
            _selectedTaskType == TaskType.safetyCritical,
          ],
          onPressed: _handleTaskTypeToggle,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Text("Standard Chore"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Text("Safety Critical"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiAssignCheckboxes(double width, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Multi-Assign",
          style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: width * 0.02),
        Wrap(
          spacing: width * 0.03,
          children: _assignees.keys.map((name) {
            return FilterChip(
              label: Text(name),
              selected: _assignees[name]!,
              onSelected: (_) => _handleAssigneeToggle(name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoProofSection(
    bool isSafetyCritical,
    double width,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Photo Proof (Required)",
          style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: width * 0.03),
        Card(
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Text("Proof required for safety-critical tasks."),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyCriticalNotes(double width, double scale) {
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      color: Colors.red.shade50,
      child: Text("Safety Critical Rules Apply"),
    );
  }

  Widget _buildAddTaskButton(double width, double height, double scale) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
        ),
        onPressed: _addTask,
        child: Text(
          "Add Task",
          style: TextStyle(fontSize: 18 * scale, color: Colors.white),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
//
// // Import for date and time formatting
// import 'package:intl/intl.dart';
// import 'package:reminder_app/AppColors/AppColors.dart';
//
// enum TaskType { standard, safetyCritical }
//
// class AddTaskScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>)? onTaskAdded; // Callback for when task is added
//   const AddTaskScreen({Key? key, this.onTaskAdded}) : super(key: key);
//
//   @override
//   State<AddTaskScreen> createState() => _AddTaskScreenState();
// }
//
// class _AddTaskScreenState extends State<AddTaskScreen> {
//   final TextEditingController _taskController = TextEditingController();
//   final Color primaryColor = const Color(0xFF9B59B6);
//
//   // State variables for Date and Time
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//
//   TaskType _selectedTaskType = TaskType.standard;
//   Map<String, bool> _assignees = {
//     'Hazrat': false,
//     'Azy': false,
//     'Everyone': false,
//   };
//   bool _isPhotoProofRequired = false;
//
//   void _handleTaskTypeToggle(int index) {
//     TaskType newType = index == 0 ? TaskType.standard : TaskType.safetyCritical;
//     setState(() {
//       _selectedTaskType = newType;
//       _isPhotoProofRequired = newType == TaskType.safetyCritical;
//     });
//   }
//
//   void _handleAssigneeToggle(String assignee) {
//     setState(() {
//       if (assignee == 'Everyone') {
//         bool currentlyEveryone = _assignees['Everyone']!;
//         _assignees['Hazrat'] = !currentlyEveryone;
//         _assignees['Azy'] = !currentlyEveryone;
//         _assignees['Everyone'] = !currentlyEveryone;
//       } else {
//         _assignees[assignee] = !_assignees[assignee]!;
//         _assignees['Everyone'] = false;
//       }
//     });
//   }
//
//   // Method to select Date
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   // Method to select Time
//   Future<void> _selectTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }
//
//   void _addTask() {
//     if (_taskController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a task description.")),
//       );
//       return;
//     }
//
//     final assigneesList =
//     _assignees.entries.where((e) => e.value).map((e) => e.key).toList();
//
//     if (assigneesList.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select at least one assignee.")),
//       );
//       return;
//     }
//
//     final String reminderType =
//     _selectedTaskType == TaskType.safetyCritical ? 'critical' : 'urgent';
//
//     // Combine date and time for full timestamp
//     final DateTime fullDateTime = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _selectedTime.hour,
//       _selectedTime.minute,
//     );
//
//     // Format the title with date/time
//     final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(fullDateTime);
//
//     final newTask = {
//       'title': "${_taskController.text.trim()} - $formattedDate",
//       'status': reminderType,
//       'icon': _selectedTaskType == TaskType.safetyCritical ? Icons.shield_outlined : Icons.checklist_rtl,
//       'dueDate': fullDateTime.toIso8601String(),
//       'done': false,
//       'assignees': assigneesList,
//       'taskType': _selectedTaskType.name,
//       'photoProofRequired': _isPhotoProofRequired,
//     };
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           "Task added! Type: ${_selectedTaskType.name}, To: ${assigneesList.join(', ')}",
//         ),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//
//     // Use the callback to pass task back to HomeScreen
//     if (widget.onTaskAdded != null) {
//       widget.onTaskAdded!(newTask);
//     } else {
//       // Fallback if callback is not provided
//       print("Task created: $newTask");
//       _taskController.clear();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final textScale = MediaQuery.of(context).textScaleFactor;
//     final isSafetyCritical = _selectedTaskType == TaskType.safetyCritical;
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(screenWidth * 0.04),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildInputCard(screenWidth, textScale),
//               SizedBox(height: screenHeight * 0.02),
//               _buildDateTimeSelectors(screenWidth, textScale),
//               SizedBox(height: screenHeight * 0.02),
//               _buildTaskTypeToggle(isSafetyCritical, screenWidth, textScale),
//               SizedBox(height: screenHeight * 0.02),
//               _buildMultiAssignCheckboxes(screenWidth, textScale),
//               SizedBox(height: screenHeight * 0.02),
//               if (_isPhotoProofRequired)
//                 _buildPhotoProofSection(isSafetyCritical, screenWidth, textScale),
//               if (isSafetyCritical)
//                 _buildSafetyCriticalNotes(screenWidth, textScale),
//               SizedBox(height: screenHeight * 0.08),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildAddTaskButton(screenWidth, screenHeight, textScale),
//     );
//   }
//
//   // Widget for Date and Time Selectors
//   Widget _buildDateTimeSelectors(double screenWidth, double textScale) {
//     final formattedDate = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
//     final formattedTime = _selectedTime.format(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("Due Date & Time", null, textScale),
//         SizedBox(height: screenWidth * 0.02),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: _buildDateTimeButton(
//                 icon: Icons.calendar_today,
//                 label: formattedDate,
//                 onTap: _selectDate,
//                 screenWidth: screenWidth,
//                 textScale: textScale,
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.04),
//             Expanded(
//               child: _buildDateTimeButton(
//                 icon: Icons.access_time,
//                 label: formattedTime,
//                 onTap: _selectTime,
//                 screenWidth: screenWidth,
//                 textScale: textScale,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDateTimeButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required double screenWidth,
//     required double textScale,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//             vertical: screenWidth * 0.03, horizontal: screenWidth * 0.02),
//         decoration: BoxDecoration(
//           color: primaryColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: primaryColor.withOpacity(0.5)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: primaryColor, size: 20),
//             SizedBox(width: screenWidth * 0.02),
//             Flexible(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14 * textScale,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputCard(double screenWidth, double textScale) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Task Details",
//               style: TextStyle(
//                   fontSize: 18 * textScale, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: screenWidth * 0.02),
//             TextField(
//               controller: _taskController,
//               minLines: 2,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: "E.g., Empty the dishwasher before 7 PM...",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey.shade50,
//               ),
//             ),
//             SizedBox(height: screenWidth * 0.02),
//             Text(
//               "AI Suggests: Assign to: Azy, Time: 7:00 PM",
//               style: TextStyle(
//                 fontSize: 12 * textScale,
//                 fontStyle: FontStyle.italic,
//                 color: primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTaskTypeToggle(
//       bool isSafetyCritical, double screenWidth, double textScale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               "Task Type: ",
//               style: TextStyle(
//                   fontSize: 16 * textScale, fontWeight: FontWeight.w600),
//             ),
//             Icon(
//               isSafetyCritical ? Icons.security : Icons.check_circle_outline,
//               color: isSafetyCritical ? Colors.red.shade600 : Colors.blue.shade600,
//               size: 20,
//             ),
//           ],
//         ),
//         SizedBox(height: screenWidth * 0.02),
//         ToggleButtons(
//           isSelected: [
//             _selectedTaskType == TaskType.standard,
//             _selectedTaskType == TaskType.safetyCritical,
//           ],
//           onPressed: _handleTaskTypeToggle,
//           borderRadius: BorderRadius.circular(8),
//           selectedBorderColor: primaryColor,
//           selectedColor: primaryColor,
//           fillColor: primaryColor.withOpacity(0.1),
//           color: Colors.grey.shade600,
//           borderWidth: 1,
//           borderColor: primaryColor.withOpacity(0.5),
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle_outline, size: 20),
//                   SizedBox(width: screenWidth * 0.02),
//                   Text("Standard Chore", style: TextStyle(fontSize: 14 * textScale)),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               child: Row(
//                 children: [
//                   Icon(Icons.shield,
//                       color:
//                       isSafetyCritical ? primaryColor : Colors.red, size: 20),
//                   SizedBox(width: screenWidth * 0.02),
//                   Text("Safety Critical", style: TextStyle(fontSize: 14 * textScale)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMultiAssignCheckboxes(double screenWidth, double textScale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Multi-Assign",
//           style: TextStyle(fontSize: 18 * textScale, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: screenWidth * 0.02),
//         Wrap(
//           spacing: screenWidth * 0.03,
//           children: _assignees.keys.map((assignee) {
//             return FilterChip(
//               label: Text(assignee, style: TextStyle(fontSize: 14 * textScale)),
//               selected: _assignees[assignee]!,
//               onSelected: (_) => _handleAssigneeToggle(assignee),
//               selectedColor: primaryColor.withOpacity(0.2),
//               checkmarkColor: primaryColor,
//             );
//           }).toList(),
//         ),
//         if (_selectedTaskType == TaskType.safetyCritical && _assignees['Everyone']!)
//           Padding(
//             padding: EdgeInsets.only(top: screenWidth * 0.02),
//             child: Text(
//               "Note: Only Leader confirmation is required for this Safety-Critical task.",
//               style: TextStyle(fontSize: 12 * textScale, color: primaryColor),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildPhotoProofSection(
//       bool isSafetyCritical, double screenWidth, double textScale) {
//     final proofLabel = "Photo Proof (Required)";
//     final proofColor = isSafetyCritical ? Colors.red.shade600 : Colors.orange.shade600;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader(proofLabel, proofColor, textScale),
//         SizedBox(height: screenWidth * 0.03),
//         Card(
//           elevation: 1,
//           color: proofColor.withOpacity(0.1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: proofColor.withOpacity(0.5)),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Proof is mandatory for Safety Critical tasks.",
//                   style: TextStyle(
//                       fontWeight: FontWeight.w600, fontSize: 14 * textScale),
//                 ),
//                 SizedBox(height: screenWidth * 0.03),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildProofOption(Icons.camera_alt, "Take Photo", proofColor, screenWidth, textScale),
//                     _buildProofOption(Icons.upload_file, "Upload Photo", proofColor, screenWidth, textScale),
//                   ],
//                 ),
//                 SizedBox(height: screenWidth * 0.02),
//                 Text(
//                   "Photos stored securely for 30 days maximum, then auto-deleted.",
//                   style: TextStyle(
//                       fontSize: 12 * textScale,
//                       fontStyle: FontStyle.italic,
//                       color: Colors.grey),
//                 ),
//                 Text(
//                   "This feature is currently Free (Health/Safety category).",
//                   style: TextStyle(
//                       fontSize: 12 * textScale,
//                       fontStyle: FontStyle.italic,
//                       color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProofOption(
//       IconData icon, String label, Color color, double screenWidth, double textScale) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("$label action triggered.")),
//             );
//           },
//           child: Container(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, size: screenWidth * 0.08, color: color),
//           ),
//         ),
//         SizedBox(height: screenWidth * 0.01),
//         Text(label, style: TextStyle(color: color, fontSize: 13 * textScale)),
//       ],
//     );
//   }
//
//   Widget _buildSafetyCriticalNotes(double screenWidth, double textScale) {
//     return Container(
//       padding: EdgeInsets.all(screenWidth * 0.03),
//       margin: EdgeInsets.only(top: screenWidth * 0.03),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Safety Critical Task Rules:",
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14 * textScale),
//           ),
//           SizedBox(height: screenWidth * 0.01),
//           Text("- Cannot Snooze (Replaced with 'Running Late (+15m)').",
//               style: TextStyle(fontSize: 13 * textScale)),
//           Text("- Requires explicit confirmation (Slide & Hold to Done).",
//               style: TextStyle(fontSize: 13 * textScale)),
//           Text("- Escalates faster to Leader/Family.", style: TextStyle(fontSize: 13 * textScale)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, Color? color, double textScale) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 18 * textScale,
//         fontWeight: FontWeight.bold,
//         color: color ?? Colors.grey.shade800,
//       ),
//     );
//   }
//
//   Widget _buildAddTaskButton(double screenWidth, double screenHeight, double textScale) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//           screenWidth * 0.04, screenHeight * 0.01, screenWidth * 0.04, screenHeight * 0.015),
//       color: Colors.white,
//       child: SafeArea(
//         child: ElevatedButton(
//           onPressed: _addTask,
//           style: ElevatedButton.styleFrom(
//             minimumSize: Size(double.infinity, screenHeight * 0.07),
//             backgroundColor: primaryColor,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(screenWidth * 0.03),
//             ),
//             elevation: 5,
//           ),
//           child: Text(
//             "Add Task",
//             style: TextStyle(
//                 fontSize: 18 * textScale,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }
// }