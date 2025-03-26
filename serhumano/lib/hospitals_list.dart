import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';  // Para generar un ID único

class Hospital {
  // Atributos
  final String id;
  final String name;
  final String address;
  final String phone; // Privado o Publico
  final String sector; // Privado o Publico
  final double latitude;
  final double longitude;

   // Constructor
  Hospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.sector,
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
List<Hospital> hospitals = [
  Hospital(
    name: 'Hospital General',
    address: 'Calle 123, Ciudad, País',
    phone: '123 456 7890',
    sector: 'Público',
    latitude: 32.50761951262851, 
    longitude: -116.92793826234407,
  ),
  Hospital(
    name: 'Clínica ABC',
    address: 'Avenida 456, Ciudad, País',
    phone: '987 654 3210',
    sector: 'Privado',
    latitude: 32.507976159722595,
    longitude: -116.92857868256071
  ),
];

// Crear los markers para mostrarlos en el mapa
Set<Marker> hospitalMarkers = hospitals.map((hospital) => hospital.createMarker()).toSet();
