import 'lugar.dart';

/// Pasaporte turístico: ganas un sello al llegar a menos de 40 m de un lugar.
class Pasaporte {
  static const double radioSello = 40;
  final Set<String> _visitados = {};

  /// Devuelve true SOLO la primera vez que se gana el sello de ese lugar.
  bool registrarSiCerca(Lugar lugar, double distanciaMetros) {
    if (distanciaMetros > radioSello) return false;
    return _visitados.add(lugar.id);
  }

  bool visitado(String id) => _visitados.contains(id);
  int get total => _visitados.length;
  double progreso(int totalLugares) => totalLugares == 0 ? 0 : total / totalLugares;
}
