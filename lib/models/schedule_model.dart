class ScheduleModel {
  final String scheduleId;
  final String title;
  final double target;
  final double repeat;
  final double lastDone;

  ScheduleModel({
    required this.scheduleId,
    required this.title,
    required this.target,
    required this.repeat,
    required this.lastDone,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduleModel(
      scheduleId: documentId,
      title: map['title'] ?? '',
      target: (map['target'] ?? 0).toDouble(),
      repeat: (map['repeat'] ?? 0).toDouble(),
      lastDone: (map['lastDone'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'target': target,
      'repeat': repeat,
      'lastDone': lastDone,
    };
  }
}