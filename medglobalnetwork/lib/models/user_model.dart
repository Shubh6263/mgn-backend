class UserModel {
  final String id;
  final String uniqueId;
  final String phoneNumber;
  final String? email;
  final String? displayName;
  final String? profileImageUrl;
  final bool biometricEnabled;

  const UserModel({
    required this.id,
    required this.uniqueId,
    required this.phoneNumber,
    this.email,
    this.displayName,
    this.profileImageUrl,
    this.biometricEnabled = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      uniqueId: json['unique_id'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unique_id': uniqueId,
        'phone_number': phoneNumber,
        'email': email,
        'display_name': displayName,
        'profile_image_url': profileImageUrl,
        'biometric_enabled': biometricEnabled,
      };

  UserModel copyWith({
    String? id,
    String? uniqueId,
    String? phoneNumber,
    String? email,
    String? displayName,
    String? profileImageUrl,
    bool? biometricEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
