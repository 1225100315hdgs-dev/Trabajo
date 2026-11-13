import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_2048/logica/grid.dart';
import 'package:nieves_2048/logica/direccion.dart';
import 'package:nieves_2048/logica/estado_juego.dart';
import 'package:nieves_2048/logica/motor_juego.dart';

void main() {
  // RONDA 10
  test('mover sin ningun desplazamiento no agrega una ficha nueva', () {
    final motor = MotorJuego();
    motor.grid = Grid([
      [2, 4, 8, 16],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
    ]);
    final vaciasAntes = motor.grid.celdas.expand((f) => f).where((v) => v == null).length;
    motor.mover(Direccion.izquierda);
    final vaciasDespues = motor.grid.celdas.expand((f) => f).where((v) => v == null).length;
    expect(vaciasDespues, vaciasAntes);
  });

  test('alcanzar el valor objetivo cambia el estado a ganado', () {
    final motor = MotorJuego();
    motor.grid = Grid([
      [1024, 1024, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
    ]);
    motor.mover(Direccion.izquierda);
    expect(motor.estado, EstadoJuego.ganado);
    expect(motor.puntaje, 2048);
  });

  // INTEGRACION
  test('una serie de movimientos combina fichas y acumula puntaje', () {
    final motor = MotorJuego();
    motor.grid = Grid([
      [2, 2, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
    ]);
    motor.mover(Direccion.izquierda);
    expect(motor.grid.celdas[0][0], 4);
    expect(motor.puntaje, 4);
    expect(motor.estado, EstadoJuego.jugando);
  });
}
