class UserProfile {
  final String fullName;
  final String designation;
  final String tagline;
  final String phoneNumber;
  final String socialHandle;
  final String? profileImagePath;
  final String? partyOrSymbolImagePath;

  const UserProfile({
    required this.fullName,
    required this.designation,
    required this.tagline,
    required this.phoneNumber,
    required this.socialHandle,
    this.profileImagePath,
    this.partyOrSymbolImagePath,
  });

  /// Factory constructor for a default sample profile in rural/regional Indian context.
  factory UserProfile.sample() {
    return const UserProfile(
      fullName: 'राजेश कुमार यादव',
      designation: 'प्रधान - ग्राम पंचायत बलीपुर',
      tagline: 'आपकी सेवा में सदैव तत्पर',
      phoneNumber: '+91 98765 43210',
      socialHandle: '@RajeshYadavPradhan',
      profileImagePath: null,
      partyOrSymbolImagePath: null,
    );
  }

  /// Factory constructor for an empty initial profile.
  factory UserProfile.empty() {
    return const UserProfile(
      fullName: '',
      designation: '',
      tagline: '',
      phoneNumber: '',
      socialHandle: '',
      profileImagePath: null,
      partyOrSymbolImagePath: null,
    );
  }

  UserProfile copyWith({
    String? fullName,
    String? designation,
    String? tagline,
    String? phoneNumber,
    String? socialHandle,
    String? profileImagePath,
    String? partyOrSymbolImagePath,
    bool clearProfileImage = false,
    bool clearPartyOrSymbolImage = false,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      designation: designation ?? this.designation,
      tagline: tagline ?? this.tagline,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      socialHandle: socialHandle ?? this.socialHandle,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
      partyOrSymbolImagePath: clearPartyOrSymbolImage
          ? null
          : (partyOrSymbolImagePath ?? this.partyOrSymbolImagePath),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'designation': designation,
      'tagline': tagline,
      'phoneNumber': phoneNumber,
      'socialHandle': socialHandle,
      'profileImagePath': profileImagePath,
      'partyOrSymbolImagePath': partyOrSymbolImagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      socialHandle: json['socialHandle'] as String? ?? '',
      profileImagePath: json['profileImagePath'] as String?,
      partyOrSymbolImagePath: json['partyOrSymbolImagePath'] as String?,
    );
  }

  bool get isConfigured => fullName.trim().isNotEmpty;
}
