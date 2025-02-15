import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:literato/controllers/mapaController.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late GoogleMapController mapController;
  final MapaController mapaController = MapaController();
  final Set<Marker> _markers = {};
  // BitmapDescriptor iconeCustomizado = BitmapDescriptor.defaultMarker;
  LatLng? _userLocation;

  // Ícones personalizados
  BitmapDescriptor iconeJogando = BitmapDescriptor.defaultMarker;
  BitmapDescriptor iconeGanhou = BitmapDescriptor.defaultMarker;
  BitmapDescriptor iconeNaoConseguiu = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    // _determinePosition();
    _loadCustomMarker();
    loadPlayersLocation();
  }

  // /// Obtém a localização atual do usuário e move a câmera para essa posição.
  // Future<void> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Verifica se a localização está ativada
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return;
  //   }

  //   // Verifica permissões
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return;
  //   }

  //   // Obtém a localização atual do usuário
  //   Position position = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     _userLocation = LatLng(position.latitude, position.longitude);
  //     _markers.add(
  //       Marker(
  //         markerId: const MarkerId("user_location"),
  //         position: _userLocation!,
  //         infoWindow: const InfoWindow(title: "Você está aqui"),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //       ),
  //     );
  //   });

  //   // Move a câmera para a localização do usuário
  //   mapController.animateCamera(
  //     CameraUpdate.newLatLngZoom(_userLocation!, 15),
  //   );
  // }

  /// Carrega o ícone personalizado redimensionado
  Future<void> _loadCustomMarker() async {
    BitmapDescriptor.asset(
      const ImageConfiguration(
          size: Size(44.5, 45.2)), // Define o tamanho do ícone
      "images/iconeJogando.png",
    ).then((icon) {
      setState(() {
        iconeJogando = icon;
      });
    });

    BitmapDescriptor.asset(
      const ImageConfiguration(
          size: Size(36.8, 37.7)), // Define o tamanho do ícone
      "images/iconeGanhou.png",
    ).then((icon) {
      setState(() {
        iconeGanhou = icon;
      });
    });

    BitmapDescriptor.asset(
      const ImageConfiguration(
          size: Size(32.5, 33.7)), // Define o tamanho do ícone
      "images/iconeNaoConseguiu.png",
    ).then((icon) {
      setState(() {
        iconeNaoConseguiu = icon;
      });
    });
  }

  /// Carrega os contatos e adiciona os marcadores ao mapa
  Future<void> loadPlayersLocation() async {
    List<Map<String, dynamic>> players =
        await mapaController.getPlayersLocation();

    for (var player in players) {
      if (player['latitude'] != 0.0 && player['longitude'] != 0.0) {
        BitmapDescriptor iconeSelecionado = iconeJogando;

        if (player['desistiu']) {
          iconeSelecionado = iconeNaoConseguiu;
        } else if (player['ganhou']) {
          iconeSelecionado = iconeGanhou;
        }

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(player["id"]),
              position: LatLng(player['latitude'], player['longitude']),
              infoWindow: InfoWindow(
                title: player["nome"],
                snippet: player['desistiu']
                    ? 'Não conseguiu'
                    : player['ganhou']
                        ? 'Ganhou'
                        : 'Jogando..',
              ),
              icon: iconeSelecionado,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Jogadores 🎮'),
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target:
              _userLocation ?? LatLng(-5.077095612158679, -42.801759773015526),
          zoom: 10,
        ),
        markers: _markers,
        myLocationEnabled: true, // Ativa o botão de localização no mapa
        myLocationButtonEnabled:
            true, // Habilita botão para centralizar no usuário
      ),
    );
  }
}
