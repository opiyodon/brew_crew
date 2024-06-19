class CustomUser {
  final String? uid;

  CustomUser({this.uid});
}

class UserData {
  final String? uid;
  final String username;
  final String? profilePicture;

  UserData({
    this.uid,
    required this.username,
    this.profilePicture,
  });
}