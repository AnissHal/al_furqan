import 'package:al_furqan/models/schools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolMap extends StatelessWidget {
  const SchoolMap({super.key, required this.school});
  final Schools school;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24))),
      child: FlutterMap(
          options: MapOptions(
            zoom: 17,
            onTap: (tapPosition, point) {
              final uri =
                  'https://www.google.com/maps/search/?api=1&query=${school.lat},${school.long}';

              launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
            },
            interactiveFlags: InteractiveFlag.none,

            center:
                LatLng(school.lat!, school.long!), // Center the map over London
          ),
          children: [
            TileLayer(
              // Bring your own tiles
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
              userAgentPackageName:
                  'com.anisshal.al-furqan', // Add your app identifier
              // And many more recommended properties!
            ),
            MarkerLayer(
              markers: [
                Marker(
                    point: LatLng(school.lat!, school.long!),
                    builder: (context) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ))
              ],
            )
          ]),
    );
  }
}
