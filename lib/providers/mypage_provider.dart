// lib/providers/mypage_provider.dart (수정본)

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeonmattaeng/models/user_model.dart'; // ✅ User 모델 임포트
import 'package:jeonmattaeng/services/user_service.dart';

// ✅ 기존 UserProfile 클래스는 삭제합니다.

class MyPageProvider with ChangeNotifier {
  User? _user; // ✅ UserProfile -> User
  bool _isLoading = false;
  bool _isUploading = false;

  User? get user => _user; // ✅ userProfile -> user
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  MyPageProvider() {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profileData = await UserService.getUserProfile();
      if (profileData != null) {
        _user = User.fromJson(profileData); // ✅ User.fromJson 사용
      }
    } catch (e) {
      print('[MyPageProvider] 사용자 정보 불러오기 실패: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateNickname(String newNickname) async {
    try {
      await UserService.updateNickname(newNickname);
      _user = _user?.copyWith(nickname: newNickname); // ✅ copyWith로 닉네임만 변경
      notifyListeners();
      return true;
    } catch (e) {
      print('[MyPageProvider] 닉네임 수정 실패: $e');
      return false;
    }
  }

  Future<bool> updateProfileImage(XFile image) async {
    _isUploading = true;
    notifyListeners();
    try {
      // ✅ updateProfileImage는 'profileImgUrl'을 반환하므로 이 부분은 그대로 둡니다.
      final newImageUrl = await UserService.updateProfileImage(image);
      if (newImageUrl != null) {
        _user = _user?.copyWith(profileImageUrl: newImageUrl); // ✅ copyWith로 이미지 URL만 변경
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('[MyPageProvider] 프로필 이미지 수정 실패: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}