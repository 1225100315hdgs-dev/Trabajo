import 'grid.dart';
import 'direccion.dart';
import 'estado_juego.dart';

class MotorJuego {
  Grid grid = Grid.vacio();
  int puntaje = 0;
  EstadoJuego estado = EstadoJuego.jugando;
  static const int objetivoVictoria = 2048;

  MotorJuego() {
    grid.agregarFichaAleatoria();
    grid.agregarFichaAleatoria();
  }

  void mover(Direccion direccion) {
    if (estado != EstadoJuego.jugando) return;

    final antes = grid.celdas.map((f) => List<int?>.from(f)).toList();
    int puntosGanados;
    switch (direccion) {
      case Direccion.izquierda:
        puntosGanados = grid.moverIzquierda();
        break;
      case Direccion.derecha:
        puntosGanados = grid.moverDerecha();
        break;
      case Direccion.arriba:
        puntosGanados = grid.moverArriba();
        break;
      case Direccion.abajo:
        puntosGanados = grid.moverAbajo();
        break;
    }
    puntaje += puntosGanados;

    if (grid.haGanado(objetivoVictoria)) {
      estado = EstadoJuego.ganado;
      return;
    }

    final huboMovimiento = !_gridsIguales(antes, grid.celdas);
    if (huboMovimiento) {
      grid.agregarFichaAleatoria();
    }

    if (!grid.hayMovimientosPosibles()) {
      estado = EstadoJuego.perdido;
    }
  }

  bool _gridsIguales(List<List<int?>> a, List<List<int?>> b) {
    for (var f = 0; f < a.length; f++) {
      for (var c = 0; c < a[f].length; c++) {
        if (a[f][c] != b[f][c]) return false;
      }
    }
    return true;
  }
}
