import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_2048/logica/grid.dart';

void main() {
  // RONDA 4
  test('moverIzquierda aplica el movimiento a las 4 filas', () {
    final grid = Grid([
      [null, 2, 2, null],
      [4, null, null, 4],
      [null, null, null, null],
      [2, 2, 2, 2],
    ]);
    final puntos = grid.moverIzquierda();
    expect(grid.celdas[0], [4, null, null, null]);
    expect(grid.celdas[1], [8, null, null, null]);
    expect(grid.celdas[2], [null, null, null, null]);
    expect(grid.celdas[3], [4, 4, null, null]);
    expect(puntos, 4 + 8 + 4 + 4);
  });

  // RONDA 5
  test('moverDerecha empuja las fichas hacia el lado opuesto', () {
    final grid = Grid([
      [2, 2, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
    ]);
    grid.moverDerecha();
    expect(grid.celdas[0], [null, null, null, 4]);
  });

  // RONDA 6
  test('moverArriba empuja las fichas de cada columna hacia arriba', () {
    final grid = Grid([
      [null, null, null, null],
      [2, null, null, null],
      [null, null, null, null],
      [2, null, null, null],
    ]);
    grid.moverArriba();
    expect(grid.celdas[0][0], 4);
  });
  test('moverAbajo empuja las fichas de cada columna hacia abajo', () {
    final grid = Grid([
      [2, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
    ]);
    grid.moverAbajo();
    expect(grid.celdas[3][0], 2);
  });

  // RONDA 7
  test('agregarFichaAleatoria coloca exactamente una ficha nueva', () {
    final grid = Grid.vacio();
    grid.agregarFichaAleatoria(aleatorio: Random(1));
    final noVacias = grid.celdas.expand((f) => f).where((v) => v != null).length;
    expect(noVacias, 1);
  });
  test('agregarFichaAleatoria no hace nada si la cuadricula esta llena', () {
    final grid = Grid(List.generate(4, (_) => List<int?>.generate(4, (_) => 2)));
    grid.agregarFichaAleatoria(aleatorio: Random(1));
    final valores = grid.celdas.expand((f) => f).toList();
    expect(valores.every((v) => v == 2), true);
  });

  // RONDA 8
  test('hayMovimientosPosibles es verdadero si hay una celda vacia', () {
    final grid = Grid.vacio();
    expect(grid.hayMovimientosPosibles(), true);
  });
  test('hayMovimientosPosibles es verdadero si hay una fusion posible', () {
    final grid = Grid([
      [2, 2, 4, 8],
      [4, 8, 16, 32],
      [2, 4, 8, 16],
      [4, 2, 4, 2],
    ]);
    expect(grid.hayMovimientosPosibles(), true);
  });
  test('hayMovimientosPosibles es falso si la cuadricula esta llena y sin fusiones', () {
    final grid = Grid([
      [2, 4, 2, 4],
      [4, 2, 4, 2],
      [2, 4, 2, 4],
      [4, 2, 4, 2],
    ]);
    expect(grid.hayMovimientosPosibles(), false);
  });

  // RONDA 9
  test('haGanado es verdadero cuando una celda alcanza el objetivo', () {
    final grid = Grid.vacio();
    grid.celdas[0][0] = 2048;
    expect(grid.haGanado(2048), true);
  });
  test('haGanado es falso si ninguna celda alcanza el objetivo', () {
    final grid = Grid.vacio();
    grid.celdas[0][0] = 1024;
    expect(grid.haGanado(2048), false);
  });
}
