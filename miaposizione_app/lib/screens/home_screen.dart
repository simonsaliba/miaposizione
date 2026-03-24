import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/position_model.dart';
import '../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialPosition();
  }

  Future<void> _loadInitialPosition() async {
    final locationService = ref.read(locationServiceProvider);
    final positions = ref.read(positionsProvider);

    positions.whenData((list) async {
      if (list.isNotEmpty) {
        _moveToPosition(list.first.latitude, list.first.longitude);
      } else {
        final position = await locationService.getCurrentPosition();
        if (position != null && mounted) {
          _moveToPosition(position.latitude, position.longitude);
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _moveToPosition(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );
  }

  Future<void> _saveCurrentPosition() async {
    final locationService = ref.read(locationServiceProvider);
    final positionsNotifier = ref.read(positionsProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final position = await locationService.getCurrentPosition();

    if (!mounted) return;
    Navigator.pop(context);

    if (position != null) {
      final positionModel = PositionModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      await positionsNotifier.addPosition(positionModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posizione salvata!'),
            backgroundColor: Colors.green,
          ),
        );
        _moveToPosition(position.latitude, position.longitude);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile ottenere la posizione'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sharePosition(PositionModel position) {
    Share.share(
      'La mia posizione:\n${position.coordinatesString}\n${position.googleMapsUrl}',
      subject: 'Condivisione posizione',
    );
  }

  Set<Marker> _buildMarkers(List<PositionModel> positions, PositionModel? selected) {
    final markers = <Marker>{};

    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final isSelected = selected != null &&
          pos.latitude == selected.latitude &&
          pos.longitude == selected.longitude;

      markers.add(
        Marker(
          markerId: MarkerId('pos_$i'),
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: pos.formattedDate,
            snippet: pos.coordinatesString,
            onTap: () => _sharePosition(pos),
          ),
          onTap: () {
            ref.read(selectedPositionProvider.notifier).state = pos;
          },
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final positions = ref.watch(positionsProvider);
    final selectedPosition = ref.watch(selectedPositionProvider);
    final lastPosition = ref.watch(lastPositionProvider);

    final initialPosition = lastPosition != null
        ? LatLng(lastPosition.latitude, lastPosition.longitude)
        : const LatLng(41.9028, 12.4964);

    return Scaffold(
      body: positions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Errore: $e')),
        data: (list) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_isLoading) {
                  _loadInitialPosition();
                }
              },
              markers: _buildMarkers(list, selectedPosition),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text(
                              'Ultima Posizione',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lastPosition?.formattedDate ?? 'Nessuna posizione salvata',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (lastPosition != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            lastPosition.coordinatesString,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'my_location',
            onPressed: () async {
              final position =
                  await ref.read(currentPositionProvider.notifier).getCurrentPosition();
              if (position != null) {
                _moveToPosition(position.latitude, position.longitude);
              }
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'save_position',
            onPressed: _saveCurrentPosition,
            icon: const Icon(Icons.add_location),
            label: const Text('Salva Posizione'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
