import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/bottom_navigation_bar.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/family_service.dart';
import 'package:reminder_app/services/user_service.dart';
import 'FamilySetupScreen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  String _selectedRole = 'Parent';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Parent / Admin',
      'value': 'Parent',
      'icon': Icons.admin_panel_settings,
      'description': 'Can manage family settings and tasks',
      'isAdmin': true,
    },
    {
      'title': 'Family Member',
      'value': 'Member',
      'icon': Icons.person,
      'description': 'Can view and complete assigned tasks',
      'isAdmin': false,
    },
    {
      'title': 'Child',
      'value': 'Child',
      'icon': Icons.child_care,
      'description': 'Simplified view for tasks',
      'isAdmin': false,
    },
  ];

  bool get _isAdminRole => _selectedRole == 'Parent';

  Future<void> _handleContinue() async {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.show(title: "Oops", message: 'Please enter your name');
      return;
    }

    // For non-admin roles, require join code
    if (!_isAdminRole && _joinCodeController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: "Oops",
        message: 'Please enter a family code to join',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final user = authService.currentUser;

      if (user != null) {
        final userService = UserService();

        // Save user profile first
        await userService.saveUser(user.uid, {
          'displayName': _nameController.text.trim(),
          'role': _selectedRole,
          'email': user.email ?? '',
          'phoneNumber': user.phoneNumber ?? '',
        }, isNewUser: true);

        if (!_isAdminRole) {
          // Non-admin: try to join family with code
          final familyService = FamilyService();
          final joinCode = _joinCodeController.text.trim().toUpperCase();
          final joinSuccess = await familyService.joinFamily(
            user.uid,
            joinCode,
          );

          if (mounted) {
            setState(() => _isLoading = false);

            if (joinSuccess) {
              // Successfully joined family -> go directly to Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavigationScreen(),
                ),
              );
            } else {
              CustomSnackbar.show(
                title: "Invalid Code",
                message:
                    "No family found with that code. Please check and try again.",
              );
            }
          }
        } else {
          // Admin: go to Family Setup to create family
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FamilySetupScreen(),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          CustomSnackbar.show(title: "Error", message: "User not logged in");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.show(
          title: "Error",
          message: "Failed to save profile: $e",
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.04),
              // Header
              Text(
                'Tell us about you',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This info helps us personalize your experience',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.06),

              // Name Input
              Text(
                'What should we call you?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g., Mom, Dad, Hazrat',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: AppColors.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Role Selection
              Text(
                'What is your role in the family?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              ..._roles.map((role) => _buildRoleOption(role)),

              // Join Code Section - Only visible for non-admin roles
              if (!_isAdminRole) ...[
                SizedBox(height: screenHeight * 0.03),
                _buildJoinCodeSection(),
              ],

              SizedBox(height: screenHeight * 0.06),

              // Continue Button
              CustomButton(
                onPressed: _isLoading ? null : _handleContinue,
                text: _isAdminRole
                    ? 'Continue to Create Family'
                    : 'Join Family',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_add, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Join Your Family',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-character code shared by your family admin',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _joinCodeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            style: const TextStyle(
              letterSpacing: 4,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: TextStyle(
                letterSpacing: 4,
                color: Colors.grey.shade400,
              ),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(Map<String, dynamic> role) {
    final isSelected = _selectedRole == role['value'];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = role['value']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                role['icon'],
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
