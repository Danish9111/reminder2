import 'package:flutter/material.dart';
import 'package:reminder_app/models/family_member.dart';
import 'package:reminder_app/models/family_model.dart';
import 'package:reminder_app/services/family_service.dart';

class FamilyProvider extends ChangeNotifier {
  final familyService = FamilyService();

  FamilyModel? _family;
  List<FamilyMember> _members = [];
  bool _isLoading = false;
  bool _isMembersLoading = false;
  String? _error;

  FamilyModel? get family => _family;
  String get familyName => _family?.name ?? '';
  String? get joinCode => _family?.joinCode;
  List<FamilyMember> get members => _members;
  bool get isLoading => _isLoading;
  bool get isMembersLoading => _isMembersLoading;
  String? get error => _error;

  Future<void> loadFamily() async {
    try {
      if (_family != null) return;
      _isLoading = true;
      _error = null;
      notifyListeners();

      final familyData = await familyService.fetchFamilyInfo();
      _family = familyData;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  //normal fetch for cache
  Future<void> loadFamilyMembers() async {
    if (_members.isNotEmpty) return;
    await fetchFamilyMembers();
  }

  //memebers refresh on refresh indicator
  Future<void> refreshFamilyMembers() async {
    _members.clear();
    await fetchFamilyMembers();
  }

  Future<void> fetchFamilyMembers() async {
    try {
      _isMembersLoading = true;
      _error = null;
      notifyListeners();

      _members = await familyService.fetchFamilyMembers();

      _isMembersLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isMembersLoading = false;
      notifyListeners();
    }
  }
}
