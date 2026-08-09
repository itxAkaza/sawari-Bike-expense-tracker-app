import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String scheduleId;
  final String title;
  final String type; // 'km' or 'date'
  final dynamic target; // Holds double (km) or Timestamp (date)
  final double repeat;
  final dynamic lastDone; // Holds double (km) or Timestamp (date)

  ScheduleModel({
    required this.scheduleId,
    required this.title,
    required this.type,
    required this.target,
    required this.repeat,
    required this.lastDone,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduleModel(
      scheduleId: documentId,
      title: map['title'] ?? '',
      type: map['type'] ?? 'km', // Defaults to 'km' if missing
      target: map['target'], // Left dynamic to capture either int/double or Timestamp
      repeat: (map['repeat'] ?? 0).toDouble(),
      lastDone: map['lastDone'], // Left dynamic to capture either int/double or Timestamp
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'target': target,
      'repeat': repeat,
      'lastDone': lastDone,
    };
  }
}