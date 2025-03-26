import 'package:flutter/material.dart';
import 'package:serhumano/hospitals_list.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  String searchQuery = ""; // Track the search query
  List<Hospital> filteredHospitals = hospitals; // Filtered list of hospitals

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle for the modal
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          TextField(
            decoration: const InputDecoration(
              labelText: "Write a hospital...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
                filteredHospitals = hospitals
                    .where((hospital) =>
                        hospital.name.toLowerCase().contains(searchQuery))
                    .toList();
              });
            },
          ),
          const SizedBox(height: 16),
          // Filtered hospital list
          Expanded(
            child: ListView.builder(
              itemCount: filteredHospitals.length,
              itemBuilder: (context, index) {
                final hospital = filteredHospitals[index];
                return ListTile(
                    title: Text(
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital.address),
                      Text(hospital.phone),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Pass the selected hospital back to the map screen
                    Navigator.pop(context, hospital);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Display the number of hospitals found
          Text(
            "${filteredHospitals.length} hospital(s) found",
            style: TextStyle(
              color: Colors.grey.withAlpha((0.8 * 255).toInt()), // Use withAlpha instead of withOpacity
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}