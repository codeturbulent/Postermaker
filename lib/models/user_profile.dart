class UserProfile {
  final String id;
  final String fullName;
  final String designation;
  final String tagline;
  final String phoneNumber;
  final String socialHandle;
  final String? profileImagePath;
  final String? partyOrSymbolImagePath;
  final List<String> topLeaderImagePaths;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.designation,
    required this.tagline,
    required this.phoneNumber,
    required this.socialHandle,
    this.profileImagePath,
    this.partyOrSymbolImagePath,
    this.topLeaderImagePaths = const [],
  });

  /// Factory constructor for a default sample profile in rural/regional Indian context.
  factory UserProfile.sample() {
    return const UserProfile(
      id: 'profile_default_sample',
      fullName: 'राजेश कुमार यादव',
      designation: 'प्रधान - ग्राम पंचायत बलीपुर',
      tagline: 'आपकी सेवा में सदैव तत्पर',
      phoneNumber: '+91 98765 43210',
      socialHandle: '@RajeshYadavPradhan',
      profileImagePath: null,
      partyOrSymbolImagePath: null,
      topLeaderImagePaths: [],
    );
  }

  /// Factory constructor for an empty initial profile.
  factory UserProfile.empty() {
    return UserProfile(
      id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      fullName: '',
      designation: '',
      tagline: '',
      phoneNumber: '',
      socialHandle: '',
      profileImagePath: null,
      partyOrSymbolImagePath: null,
      topLeaderImagePaths: const [],
    );
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? designation,
    String? tagline,
    String? phoneNumber,
    String? socialHandle,
    String? profileImagePath,
    String? partyOrSymbolImagePath,
    List<String>? topLeaderImagePaths,
    bool clearProfileImage = false,
    bool clearPartyOrSymbolImage = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
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
      topLeaderImagePaths: topLeaderImagePaths ?? this.topLeaderImagePaths,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'designation': designation,
      'tagline': tagline,
      'phoneNumber': phoneNumber,
      'socialHandle': socialHandle,
      'profileImagePath': profileImagePath,
      'partyOrSymbolImagePath': partyOrSymbolImagePath,
      'topLeaderImagePaths': topLeaderImagePaths,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ??
          'profile_${DateTime.now().millisecondsSinceEpoch}',
      fullName: json['fullName'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      socialHandle: json['socialHandle'] as String? ?? '',
      profileImagePath: json['profileImagePath'] as String?,
      partyOrSymbolImagePath: json['partyOrSymbolImagePath'] as String?,
      topLeaderImagePaths: (json['topLeaderImagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  bool get isConfigured => fullName.trim().isNotEmpty;
}
