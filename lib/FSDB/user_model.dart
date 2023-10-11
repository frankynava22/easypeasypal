class UserModel {
  final String? id;
  final String fullName;
  final String email;

  UserModel({
    this.id,
    required this.email,
    required this.fullName,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
    };
  }
}
