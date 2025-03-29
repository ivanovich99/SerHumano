import 'package:flutter/material.dart';
import 'package:serhumano/hospitals_list.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  String searchQuery = "";
  String? selectedSectorFilter; // Track the selected sector filter
  List<Hospital> filteredHospitals = hospitals;

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
          // Filter buttons for sector
          // Search bar
          TextField(
            decoration: const InputDecoration(
              labelText: "Search hospitals...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
                applyFilters();
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
                    Navigator.pop(context, hospital);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Replace the number of hospitals found with filter buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSectorFilter = "Public";
                    applyFilters();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSectorFilter == "Public"
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Icon(Icons.public),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSectorFilter = "Private";
                    applyFilters();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSectorFilter == "Private"
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Icon(Icons.lock),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSectorFilter = null; // Clear the filter
                    applyFilters();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSectorFilter == null
                      ? Colors.red
                      : Colors.grey,
                ),
                child: const Icon(Icons.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Apply filters to the hospital list
  void applyFilters() {
    setState(() {
      filteredHospitals = hospitals
          .where((hospital) =>
              (selectedSectorFilter == null ||
                  hospital.sector == selectedSectorFilter) &&
              hospital.name.toLowerCase().contains(searchQuery))
          .toList();
    });
  }
}