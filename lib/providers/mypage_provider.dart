// lib/providers/mypage_provider.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeonmattaeng/services/auth_service.dart';

// 사용자 프로필 데이터를 담을 모델 클래스
class UserProfile {
  final String nickname;
  final String? profileImageUrl;

  UserProfile({required this.nickname, this.profileImageUrl});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] ?? '익명',
      profileImageUrl: json['profileImgUrl'],
    );
  }
}

class MyPageProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isUploading = false; // 이미지 업로드 상태

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  MyPageProvider() {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profileData = await AuthService.getUserProfile();
      if (profileData != null) {
        _userProfile = UserProfile.fromJson(profileData);
      }
    } catch (e) {
      print('[MyPageProvider] 사용자 정보 불러오기 실패: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateNickname(String newNickname) async {
    try {
      await AuthService.updateNickname(newNickname);
      _userProfile = UserProfile(nickname: newNickname, profileImageUrl: _userProfile?.profileImageUrl);
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
      final newImageUrl = await AuthService.updateProfileImage(image);
      if (newImageUrl != null) {
        _userProfile = UserProfile(nickname: _userProfile!.nickname, profileImageUrl: newImageUrl);
        _isUploading = false;
        notifyListeners();
        return true;
      }
      _isUploading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('[MyPageProvider] 프로필 이미지 수정 실패: $e');
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}