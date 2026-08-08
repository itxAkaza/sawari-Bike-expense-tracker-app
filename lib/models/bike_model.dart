import 'package:cloud_firestore/cloud_firestore.dart';

class BikeModel {
  final String bikeId;
  final String userId;
  final String brand;
  final String model;
  final String nickname;
  final String registration; // <-- Added
  final String year;         // <-- Added
  final double currentOdometer;
  final double firstOdometer;
  final String imageUrl;
  final double totalFuelSpend;
  final double totalMaintenanceSpend;
  final double totalRepairSpend;
  final double totalLiters;
  final DateTime? createdAt;

  BikeModel({
    required this.bikeId,
    required this.userId,
    required this.brand,
    required this.model,
    required this.nickname,
    required this.registration, // <-- Added
    required this.year,         // <-- Added
    required this.currentOdometer,
    required this.firstOdometer,
    required this.imageUrl,
    required this.totalFuelSpend,
    required this.totalMaintenanceSpend,
    required this.totalRepairSpend,
    required this.totalLiters,
    this.createdAt,
  });

  factory BikeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BikeModel(
      bikeId: documentId,
      userId: map['userId'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      nickname: map['nickname'] ?? '',
      registration: map['registration'] ?? '', // <-- Added
      year: map['year'] ?? '',                 // <-- Added
      currentOdometer: (map['currentOdometer'] ?? 0).toDouble(),
      firstOdometer: (map['firstOdometer'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      totalFuelSpend: (map['totalFuelSpend'] ?? 0).toDouble(),
      totalMaintenanceSpend: (map['totalMaintenanceSpend'] ?? 0).toDouble(),
      totalRepairSpend: (map['totalRepairSpend'] ?? 0).toDouble(),
      totalLiters: (map['totalLiters'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'brand': brand,
      'model': model,
      'nickname': nickname,
      'registration': registration, // <-- Added
      'year': year,                 // <-- Added
      'currentOdometer': currentOdometer,
      'firstOdometer': firstOdometer,
      'imageUrl': imageUrl,
      'totalFuelSpend': totalFuelSpend,
      'totalMaintenanceSpend': totalMaintenanceSpend,
      'totalRepairSpend': totalRepairSpend,
      'totalLiters': totalLiters,
    };
  }
}