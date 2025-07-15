import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMessageWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool isCurrentUser;
  final VoidCallback onTapMap;

  const LocationMessageWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.isCurrentUser,
    required this.onTapMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapMap,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser ? const Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(latitude, longitude),
                    zoom: 15,
                    interactiveFlags: InteractiveFlag.none, // Không cho zoom/di chuyển
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.friendzoneapp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: isCurrentUser ? Colors.white : Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Đã chia sẻ vị trí',
                style: TextStyle(
                  fontSize: 16,
                  color: isCurrentUser ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Nhấn để xem trên Google Maps',
                style: TextStyle(
                  fontSize: 13,
                  color: isCurrentUser ? Colors.white70 : Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
} 