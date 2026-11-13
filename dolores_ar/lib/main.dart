import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dominio/pasaporte.dart';
import 'presentacion/pantalla_inicio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // La brújula y la cámara se comportan mejor con el teléfono en vertical.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
    title: 'Dolores AR',
    theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
    home: PantallaInicio(pasaporte: Pasaporte()),
  ));
}
