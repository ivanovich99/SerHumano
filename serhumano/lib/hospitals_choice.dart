import 'package:flutter/material.dart';
import 'package:serhumano/hospitals_list.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  String searchQuery = "";
  String? selectedSectorFilter; // Track the selected sector filter
  List<Hospital> filteredHospitals = hospitals;
  Hospital? selectedHospital; // Track the currently selected hospital

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
                final isSelected = selectedHospital == hospital;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggle selection
                          selectedHospital =
                              isSelected ? null : hospital; // Deselect if already selected
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        color: isSelected ? Colors.grey[300] : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hospital.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(hospital.address),
                                Text(hospital.phone),
                              ],
                            ),
                            Icon(
                              Icons.info, // Replace the arrow with an info icon
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: isSelected
                          ? Row(
                              key: ValueKey(hospital.id),
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Open the hospital's webpage
                                    if (hospital.website.isNotEmpty) {
                                      launchUrl(Uri.parse(hospital.website));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 240, 137, 105),
                                  ),
                                  icon: const Icon(Icons.find_in_page),
                                  label: const Text(
                                    "Página web",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, // Make the text bold
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Start trip to the hospital
                                    Navigator.pop(context, hospital);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 240, 137, 105),
                                  ),
                                  icon: const Icon(Icons.directions),
                                  label: const Text(
                                    "Iniciar viaje",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, // Make the text bold
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8), // Add spacing below the buttons
                  ],
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