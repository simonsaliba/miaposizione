import 'package:hive/hive.dart';
import '../models/position_model.dart';

class StorageService {
  static const String _boxName = 'positions';
  late Box<PositionModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<PositionModel>(_boxName);
  }

  Future<void> savePosition(PositionModel position) async {
    await _box.add(position);
  }

  List<PositionModel> getAllPositions() {
    final positions = _box.values.toList();
    positions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return positions;
  }

  PositionModel? getLastPosition() {
    final positions = getAllPositions();
    return positions.isNotEmpty ? positions.first : null;
  }

  Future<void> deletePosition(int index) async {
    await _box.deleteAt(index);
  }

  Future<void> deleteAllPositions() async {
    await _box.clear();
  }

  int get positionCount => _box.length;
}
