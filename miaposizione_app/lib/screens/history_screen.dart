import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/position_model.dart';
import '../providers/providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final Function(int) onNavigateToMap;

  const HistoryScreen({super.key, required this.onNavigateToMap});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  GoogleMapController? _mapController;
  PositionModel? _selectedPosition;

  void _showOnMap(PositionModel position) {
    ref.read(selectedPositionProvider.notifier).state = position;
    widget.onNavigateToMap(0);
  }

  void _sharePosition(PositionModel position) {
    Share.share(
      'La mia posizione:\n${position.coordinatesString}\n${position.googleMapsUrl}',
      subject: 'Condivisione posizione',
    );
  }

  void _deletePosition(int index, PositionModel position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Posizione'),
        content: const Text('Sei sicuro di voler eliminare questa posizione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(positionsProvider.notifier).deletePosition(index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Posizione eliminata')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_selectedPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: LatLng(_selectedPosition!.latitude, _selectedPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final positions = ref.watch(positionsProvider);

    return Scaffold(
      body: positions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessuna posizione salvata',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tocca il pulsante + per salvare la tua posizione',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition != null
                        ? LatLng(_selectedPosition!.latitude, _selectedPosition!.longitude)
                        : LatLng(list.first.latitude, list.first.longitude),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _buildMarkers(),
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${list.length} posizione${list.length != 1 ? 'i' : ''}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (list.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Elimina Tutto'),
                              content: const Text(
                                  'Sei sicuro di voler eliminare tutte le posizioni?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Annulla'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ref.read(positionsProvider.notifier).deleteAll();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Tutte le posizioni eliminate')),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text('Elimina Tutto'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_sweep, size: 18),
                        label: const Text('Elimina tutto'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final position = list[index];
                    final isSelected = _selectedPosition != null &&
                        position.latitude == _selectedPosition!.latitude &&
                        position.longitude == _selectedPosition!.longitude;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.location_on,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        title: Text(position.formattedDate),
                        subtitle: Text(
                          position.coordinatesString,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'map':
                                _showOnMap(position);
                                break;
                              case 'share':
                                _sharePosition(position);
                                break;
                              case 'delete':
                                _deletePosition(index, position);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'map',
                              child: ListTile(
                                leading: Icon(Icons.map),
                                title: Text('Mostra su mappa'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: ListTile(
                                leading: Icon(Icons.share),
                                title: Text('Condividi'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Elimina',
                                    style: TextStyle(color: Colors.red)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPosition = position;
                          });
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(position.latitude, position.longitude),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
