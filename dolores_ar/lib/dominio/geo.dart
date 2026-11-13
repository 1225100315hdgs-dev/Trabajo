import 'dart:math' as math;

class Coordenada {
  final double lat;
  final double lon;
  const Coordenada(this.lat, this.lon);

  @override
  String toString() => '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
}

const double _radioTierra = 6371000.0; // metros

double _rad(double grados) => grados * math.pi / 180;
double _grados(double rad) => rad * 180 / math.pi;

/// Distancia en metros entre dos puntos de la Tierra (fórmula de Haversine).
double distanciaMetros(Coordenada a, Coordenada b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) * math.cos(_rad(b.lat)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * _radioTierra * math.asin(math.sqrt(h.clamp(0.0, 1.0).toDouble()));
}

/// Rumbo (0° = norte, 90° = este, 180° = sur, 270° = oeste) para ir de [a] a [b].
double rumboGrados(Coordenada a, Coordenada b) {
  final dLon = _rad(b.lon - a.lon);
  final lat1 = _rad(a.lat);
  final lat2 = _rad(b.lat);
  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  return normalizar360(_grados(math.atan2(y, x)));
}

/// Lleva cualquier ángulo al rango 0 <= g < 360.
double normalizar360(double g) => ((g % 360) + 360) % 360;

/// Cuánto hay que girar (en grados, de -180 a 180) para pasar de [actual] a [objetivo].
/// Positivo = girar a la derecha. Resuelve el problema del salto 359° -> 1°.
double diferenciaAngular(double objetivo, double actual) {
  var d = normalizar360(objetivo - actual);
  if (d > 180) d -= 360;
  return d;
}

/// Filtro pasa-bajas circular: suaviza la brújula sin romperse en el salto 359°/0°.
/// [alfa] cerca de 0 = muy suave y lento; cerca de 1 = rápido y tembloroso.
double suavizarAngulo(double anterior, double nuevo, {double alfa = 0.2}) =>
    normalizar360(anterior + alfa * diferenciaAngular(nuevo, anterior));

/// Posición horizontal en pantalla (0 = borde izquierdo, 1 = borde derecho)
/// o null si el objeto queda fuera del campo de visión de la cámara.
double? posicionHorizontal(double diferencia, {double campoVision = 60}) {
  if (diferencia.abs() > campoVision / 2) return null;
  return 0.5 + diferencia / campoVision;
}

String formatearDistancia(double metros) =>
    metros < 1000 ? '${metros.round()} m' : '${(metros / 1000).toStringAsFixed(1)} km';

String nombreCardinal(double grados) {
  const puntos = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
  return puntos[((normalizar360(grados) + 22.5) ~/ 45) % 8];
}
