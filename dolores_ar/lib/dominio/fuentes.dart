import 'geo.dart';

/// Contratos: el resto de la app NO sabe si la posición viene del GPS real
/// o de un simulador. Esa ignorancia es lo que permite probar y hacer demos.
abstract class FuentePosicion {
  Stream<Coordenada> get posiciones;
}

abstract class FuenteBrujula {
  /// Rumbo en grados (0 = norte).
  Stream<double> get rumbos;
}
