import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'datos/base_datos.dart';
import 'datos/repositorio_productos.dart';
import 'datos/repositorio_ventas.dart';
import 'presentacion/caja_viewmodel.dart';
import 'presentacion/pantalla_caja.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'El punto de venta usa SQLite y no funciona en el navegador.\n'
              'Ejecútalo en Windows o Android.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
  }

  // En escritorio SQLite se usa vía FFI. En Android/iOS usa sqflite normal.
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final db = await BaseDatos.abrir();
  final productos = RepositorioProductos(db);
  await productos.sembrarEjemplos();
  runApp(MaterialApp(
    title: 'Punto de Venta Dolores',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: PantallaCaja(vm: CajaViewModel(productos, RepositorioVentas(db))),
  ));
}