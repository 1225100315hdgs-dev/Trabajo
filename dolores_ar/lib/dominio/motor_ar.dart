import 'geo.dart';
import 'lugar.dart';

/// Un lugar ya convertido a "coordenadas de pantalla".
class LugarVisible {
  final Lugar lugar;
  final double distancia; // metros
  final double x; // 0 izquierda .. 1 derecha
  final double profundidad; // 0 = pegado a ti .. 1 = en el límite del radio
  final double escala; // 1.2 cerca .. 0.6 lejos
  const LugarVisible(this.lugar, this.distancia, this.x, this.profundidad, this.escala);
}

/// El cerebro de la realidad aumentada: dado dónde estás y hacia dónde miras,
/// ¿qué lugares aparecen en pantalla y en qué posición?
///
/// RETO del manual: [categorias] (opcional) filtra los lugares; si es null o
/// está vacío se muestran todas las categorías.
List<LugarVisible> calcularVisibles({
  required Coordenada usuario,
  required double rumbo,
  required List<Lugar> lugares,
  double campoVision = 60,
  double radioMax = 2000,
  Set<Categoria>? categorias,
}) {
  final resultado = <LugarVisible>[];
  for (final l in lugares) {
    if (categorias != null && categorias.isNotEmpty && !categorias.contains(l.categoria)) {
      continue;
    }
    final d = distanciaMetros(usuario, l.coordenada);
    if (d > radioMax) continue;
    final dif = diferenciaAngular(rumboGrados(usuario, l.coordenada), rumbo);
    final x = posicionHorizontal(dif, campoVision: campoVision);
    if (x == null) continue;
    final profundidad = (d / radioMax).clamp(0.0, 1.0).toDouble();
    resultado.add(LugarVisible(l, d, x, profundidad, 1.2 - 0.6 * profundidad));
  }
  // Los lejanos primero: así los cercanos se dibujan encima.
  resultado.sort((a, b) => b.distancia.compareTo(a.distancia));
  return resultado;
}
