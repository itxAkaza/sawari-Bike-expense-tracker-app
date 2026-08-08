import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryLogModel {
  final String logId;
  final String type; // "fuel", "maintenance", "repair"
  final String category;
  final double amount;
  final double odometer;
  final double? liters; // Nullable because maintenance/repair won't have liters
  final bool isOneTimeRepair;
  final String note;
  final DateTime? datetime;

  HistoryLogModel({
    required this.logId,
    required this.type,
    required this.category,
    required this.amount,
    required this.odometer,
    this.liters,
    required this.isOneTimeRepair,
    required this.note,
    this.datetime,
  });

  factory HistoryLogModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HistoryLogModel(
      logId: documentId,
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      odometer: (map['odometer'] ?? 0).toDouble(),
      liters: map['liters'] != null ? (map['liters'] as num).toDouble() : null,
      isOneTimeRepair: map['isOneTimeRepair'] ?? false,
      note: map['note'] ?? '',
      datetime: map['datetime'] != null ? (map['datetime'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'odometer': odometer,
      'liters': liters,
      'isOneTimeRepair': isOneTimeRepair,
      'note': note,
      'datetime': datetime != null ? Timestamp.fromDate(datetime!) : FieldValue.serverTimestamp(),
    };
  }
}