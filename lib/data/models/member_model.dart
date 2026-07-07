class Member {
  final int id;
  final String name;
  final String periodId;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;

  Member({
    required this.id,
    required this.name,
    required this.periodId,
    required this.duration,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'periodId': periodId,
    'duration': duration,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] is String ? int.parse(json['id']) : json['id'],
    name: json['name'],
    periodId: json['periodId'].toString(),
    duration: json['duration'].toString(),
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
  );

  Member copyWith({
    int? id,
    String? name,
    String? periodId,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      periodId: periodId ?? this.periodId,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
