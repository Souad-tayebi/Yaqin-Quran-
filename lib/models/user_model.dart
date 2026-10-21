class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String email;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'email': email,
    };
  }
}
