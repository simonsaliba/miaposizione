import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/position_model.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final positionsProvider =
    StateNotifierProvider<PositionsNotifier, AsyncValue<List<PositionModel>>>(
        (ref) {
  return PositionsNotifier(ref.read(storageServiceProvider));
});

final lastPositionProvider = Provider<PositionModel?>((ref) {
  final positions = ref.watch(positionsProvider);
  return positions.maybeWhen(
    data: (list) => list.isNotEmpty ? list.first : null,
    orElse: () => null,
  );
});

final currentPositionProvider =
    StateNotifierProvider<CurrentPositionNotifier, Position?>((ref) {
  return CurrentPositionNotifier(ref.read(locationServiceProvider));
});

final selectedPositionProvider = StateProvider<PositionModel?>((ref) => null);

class PositionsNotifier extends StateNotifier<AsyncValue<List<PositionModel>>> {
  final StorageService _storageService;

  PositionsNotifier(this._storageService) : super(const AsyncValue.loading()) {
    loadPositions();
  }

  Future<void> loadPositions() async {
    try {
      final positions = _storageService.getAllPositions();
      state = AsyncValue.data(positions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPosition(PositionModel position) async {
    await _storageService.savePosition(position);
    await loadPositions();
  }

  Future<void> deletePosition(int index) async {
    await _storageService.deletePosition(index);
    await loadPositions();
  }

  Future<void> deleteAll() async {
    await _storageService.deleteAllPositions();
    await loadPositions();
  }
}

class CurrentPositionNotifier extends StateNotifier<Position?> {
  final LocationService _locationService;

  CurrentPositionNotifier(this._locationService) : super(null);

  Future<Position?>> getCurrentPosition() async {
    final position = await _locationService.getCurrentPosition();
    state = position;
    return position;
  }
}

final mapControllerProvider = Provider<dynamic>((ref) => null);
