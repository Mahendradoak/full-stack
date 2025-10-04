class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> skills;
  final String bio;
  final String resumeLink;
  final List<String> savedJobs;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.skills,
    required this.bio,
    required this.resumeLink,
    required this.savedJobs,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'] ?? '',
      resumeLink: json['resumeLink'] ?? '',
      savedJobs: List<String>.from(json['savedJobs'] ?? []),
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'skills': skills,
      'bio': bio,
      'resumeLink': resumeLink,
      'savedJobs': savedJobs,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? skills,
    String? bio,
    String? resumeLink,
    List<String>? savedJobs,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      resumeLink: resumeLink ?? this.resumeLink,
      savedJobs: savedJobs ?? this.savedJobs,
      role: role ?? this.role,
    );
  }

  bool isJobSaved(String jobId) {
    return savedJobs.contains(jobId);
  }
}