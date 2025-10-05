class JobModel {
  final String id;
  final String title;
  final String company;
  final String description;
  final List<String> requirements;
  final String location;
  final String salary;
  final String jobType;
  final String status;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.requirements,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.status,
    required this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      description: json['description'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      location: json['location'] ?? '',
      salary: json['salary'] ?? 'Not specified',
      jobType: json['jobType'] ?? 'Full-time',
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} month(s) ago';
    if (difference.inDays > 0) return '${difference.inDays} day(s) ago';
    if (difference.inHours > 0) return '${difference.inHours} hour(s) ago';
    return 'Just now';
  }

  String get jobTypeIcon {
    switch (jobType.toLowerCase()) {
      case 'remote': return '🏠';
      case 'full-time': return '💼';
      case 'part-time': return '⏰';
      case 'contract': return '📝';
      case 'internship': return '🎓';
      default: return '💼';
    }
  }
}