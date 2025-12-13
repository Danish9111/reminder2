import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController(
    text: 'School Drop-off',
  );
  final TextEditingController _notesController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedMembers = [];
  bool _setReminder = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _familyMembers = [
    {'name': 'Mom', 'avatar': 'M', 'color': Color(0xFF9B59B6)},
    {'name': 'Dad', 'avatar': 'D', 'color': Color(0xFF1ABC9C)},
    {'name': 'Emma', 'avatar': 'E', 'color': Color(0xFFF4D03F)},
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF34495E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Task',
          style: TextStyle(
            color: Color(0xFF34495E),
            fontWeight: FontWeight.w600,
            fontSize: screenHeight * 0.025,
          ),
        ),
      ),
      body: Column(
        children: [
          // Expanded Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Task Name
                  TextField(
                    controller: _taskNameController,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Color(0xFF34495E),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      labelStyle: TextStyle(
                        color: Color(0xFF34495E).withOpacity(0.6),
                      ),
                      prefixIcon: Icon(Icons.school, color: Color(0xFF9B59B6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFECF0F1),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF9B59B6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: EdgeInsets.all(screenHeight * 0.02),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFECF0F1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF9B59B6),
                                  size: screenHeight * 0.025,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    color: Color(0xFF34495E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: EdgeInsets.all(screenHeight * 0.02),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFECF0F1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Color(0xFF9B59B6),
                                  size: screenHeight * 0.025,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  _selectedTime.format(context),
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    color: Color(0xFF34495E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Assign to Members
                  Text(
                    'Assign To',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34495E),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  Wrap(
                    spacing: screenWidth * 0.03,
                    runSpacing: screenHeight * 0.015,
                    children: _familyMembers.map((member) {
                      final isSelected = _selectedMembers.contains(
                        member['name'],
                      );
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedMembers.remove(member['name']);
                            } else {
                              _selectedMembers.add(member['name']);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? member['color'].withOpacity(0.1)
                                : Color(0xFFECF0F1).withOpacity(0.5),
                            border: Border.all(
                              color: isSelected
                                  ? member['color']
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: screenHeight * 0.025,
                                backgroundColor: member['color'],
                                child: Text(
                                  member['avatar'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.015,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                member['name'],
                                style: TextStyle(
                                  fontSize: screenHeight * 0.017,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF34495E),
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: screenWidth * 0.01),
                                Icon(
                                  Icons.check_circle,
                                  size: screenHeight * 0.02,
                                  color: member['color'],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: screenHeight * 0.017,
                      color: Color(0xFF34495E),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      labelStyle: TextStyle(
                        color: Color(0xFF34495E).withOpacity(0.6),
                      ),
                      hintText: 'Add any important details...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFECF0F1),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF9B59B6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Reminder Toggle
                  Container(
                    padding: EdgeInsets.all(screenHeight * 0.02),
                    decoration: BoxDecoration(
                      color: Color(0xFFECF0F1).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Color(0xFF9B59B6),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set Reminder',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.018,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF34495E),
                                ),
                              ),
                              Text(
                                'Get notified 30 min before',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.014,
                                  color: Color(0xFF34495E).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _setReminder,
                          onChanged: (value) {
                            setState(() => _setReminder = value);
                          },
                          activeColor: Color(0xFF9B59B6),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.08), // Bottom padding
                ],
              ),
            ),
          ),

          // Create Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B59B6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Create Task',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: Color(0xFF9B59B6))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: Color(0xFF9B59B6))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _createTask() {
    if (_taskNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task name'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainDashboardScreen()),
      );
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Main Dashboard - Next artifact')),
    );
  }
}
