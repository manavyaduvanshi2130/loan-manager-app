class User {
  final String fullName;
  final String mobileNumber;
  final String email;

  User({
    required this.fullName,
    required this.mobileNumber,
    required this.email,
  });

  // Factory constructor for creating User from JSON (if needed later)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'] as String,
      mobileNumber: json['mobileNumber'] as String,
      email: json['email'] as String,
    );
  }

  // Method to convert User to JSON (if needed later)
  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'mobileNumber': mobileNumber, 'email': email};
  }

  // Copy with method for immutability
  User copyWith({String? fullName, String? mobileNumber, String? email}) {
    return User(
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'User(fullName: $fullName, mobileNumber: $mobileNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.fullName == fullName &&
        other.mobileNumber == mobileNumber &&
        other.email == email;
  }

  @override
  int get hashCode =>
      fullName.hashCode ^ mobileNumber.hashCode ^ email.hashCode;
}
