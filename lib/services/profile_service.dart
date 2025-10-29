import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileService extends ChangeNotifier {
  List<Profile> _profiles = [
    Profile(name: 'Alice', bio: 'Loves hiking and coding.'),
    Profile(name: 'Bob', bio: 'Enjoys playing guitar and reading.'),
    Profile(name: 'Charlie', bio: 'Passionate about photography and travel.'),
  ];

  List<Profile> get profiles => _profiles;

  void removeProfile() {
    if (_profiles.isNotEmpty) {
      _profiles.removeLast();
      notifyListeners();
    }
  }

  void addProfile(Profile profile) {
    _profiles.add(profile);
    notifyListeners();
  }
}