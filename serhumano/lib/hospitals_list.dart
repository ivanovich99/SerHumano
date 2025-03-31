import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';  // Para generar un ID único
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class Hospital {
  // Atributos
  final String id;
  final String name;
  final String sector; // Privado o Publico
  final String address;
  final String phone; 
  final String email; // Correo electrónico
  final String website; // URL del sitio web
  final double latitude;
  final double longitude;

   // Constructor
  Hospital({
    required this.name,
    required this.sector,
    required this.address,
    this.phone  = "",
    this.email = "", // Correo electrónico opcional
    this.website = "", // URL del sitio web opcional
    required this.latitude,
    required this.longitude,
  }) : id = Uuid().v4(); // Generar ID único al crear el hospital

  // Método para crear un Marker de Google Maps
  Marker createMarker() {
    return Marker(
      markerId: MarkerId(id), // Usamos el nombre del hospital como ID único
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: name,
        snippet: address,
      ),
    );
  }
}

// Crear una lista de hospitales
List<Hospital> hospitals = [];

Future<void> loadHospitalsFromCsv() async {
  try {
    // Load the CSV file from assets
    final csvData = await rootBundle.loadString('assets/INEGI.csv');

    // Parse the CSV data
    final List<List<dynamic>> rows = const CsvToListConverter(eol: '\n').convert(csvData);

    // Skip the header row and map the data to Hospital objects
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      // Ensure the website URL is properly formatted
      String website = row[37] ?? ''; // "Sitio en Internet"
      if (website.isNotEmpty && !website.startsWith('http://') && !website.startsWith('https://')) {
        website = 'http://$website'; // Add "http://" if missing
      }

      // Map the CSV columns to Hospital attributes
      final hospital = Hospital(
        name: row[2], // "Nombre de la Unidad Económica"
        sector: row[5], // "Nombre de clase de la actividad"
        address: '${row[7]} ${row[8]}', // "Tipo de vialidad" + "Nombre de la vialidad"
        phone: row[35] ?? '', // "Número de teléfono"
        email: row[36] ?? '', // "Correo electrónico"
        website: website, // Corrected website URL
        latitude: double.tryParse(row[39].toString()) ?? 0.0, // "Latitud"
        longitude: double.tryParse(row[40].toString()) ?? 0.0, // "Longitud"
      );

      hospitals.add(hospital);
    }
  } catch (e) {
    print('Error loading hospitals from CSV: $e');
  }
}

// Crear los markers para mostrarlos en el mapa
Set<Marker> hospitalMarkers = hospitals.map((hospital) => hospital.createMarker()).toSet();

