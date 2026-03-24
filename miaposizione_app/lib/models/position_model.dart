import 'package:hive/hive.dart';

part 'position_model.g.dart';

@HiveType(typeId: 0)
class PositionModel extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final DateTime timestamp;

  PositionModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  String get googleMapsUrl =>
      'https://www.google.com/maps?q=$latitude,$longitude';

  String get formattedDate {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get coordinatesString =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
