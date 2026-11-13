import 'package:flutter_test/flutter_test.dart';
import 'package:tanda_dolorena/modelos/participante.dart';
import 'package:tanda_dolorena/modelos/tanda.dart';
import 'package:tanda_dolorena/logica/resultado_aportacion.dart';
import 'package:tanda_dolorena/logica/resultado_cierre.dart';
import 'package:tanda_dolorena/logica/servicio_tanda.dart';

Tanda _crearTandaDePrueba() {
  return Tanda(
    participantes: [
      Participante(id: 'p1', nombre: 'Ana'),
      Participante(id: 'p2', nombre: 'Beto'),
      Participante(id: 'p3', nombre: 'Carla'),
    ],
    ordenTurnos: ['p1', 'p2', 'p3'],
    montoAportacion: 200,
  );
}

void _completarRonda(ServicioTanda servicio) {
  servicio.registrarAportacion('p1');
  servicio.registrarAportacion('p2');
  servicio.registrarAportacion('p3');
  servicio.cerrarRondaYAvanzar();
}

void main() {
  // RONDA 1
  test('registrar una aportacion valida la agrega a la ronda actual', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    final resultado = servicio.registrarAportacion('p1');
    expect(resultado, ResultadoAportacion.registrada);
    expect(tanda.aportacionesRondaActual.contains('p1'), true);
  });

  // RONDA 2
  test('un participante no puede aportar dos veces en la misma ronda', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    servicio.registrarAportacion('p1');
    final segundoIntento = servicio.registrarAportacion('p1');
    expect(segundoIntento, ResultadoAportacion.yaAporto);
  });

  // RONDA 3
  test('alguien que no pertenece a la tanda no puede aportar', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    final resultado = servicio.registrarAportacion('desconocido');
    expect(resultado, ResultadoAportacion.participanteInvalido);
  });

  // RONDA 4
  test('puedeCerrarRonda es falso si falta algun participante por aportar', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    servicio.registrarAportacion('p1');
    servicio.registrarAportacion('p2');
    expect(servicio.puedeCerrarRonda(), false);
  });

  test('puedeCerrarRonda es verdadero cuando todos ya aportaron', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    servicio.registrarAportacion('p1');
    servicio.registrarAportacion('p2');
    servicio.registrarAportacion('p3');
    expect(servicio.puedeCerrarRonda(), true);
  });

  // RONDA 5
  test('cerrar la ronda entrega el turno al beneficiario y avanza', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    servicio.registrarAportacion('p1');
    servicio.registrarAportacion('p2');
    servicio.registrarAportacion('p3');
    final cierre = servicio.cerrarRondaYAvanzar();
    expect(cierre.resultado, ResultadoCierre.rondaCerrada);
    expect(cierre.beneficiario!.id, 'p1');
    expect(tanda.participantes.firstWhere((p) => p.id == 'p1').yaRecibioTurno, true);
    expect(tanda.turnoActual, 1);
    expect(tanda.aportacionesRondaActual.isEmpty, true);
  });

  // RONDA 6
  test('no se puede cerrar la ronda si algun participante no ha aportado', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    servicio.registrarAportacion('p1');
    servicio.registrarAportacion('p2'); // p3 no aporta
    final cierre = servicio.cerrarRondaYAvanzar();
    expect(cierre.resultado, ResultadoCierre.faltanAportaciones);
    expect(cierre.beneficiario, isNull);
    expect(tanda.turnoActual, 0);
  });

  // RONDA 7
  test('haTerminado es falso mientras queden turnos pendientes', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    expect(servicio.haTerminado(), false);
  });

  test('haTerminado es verdadero cuando todos ya recibieron su turno', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    for (var i = 0; i < 3; i++) {
      _completarRonda(servicio);
    }
    expect(servicio.haTerminado(), true);
  });

  test('no se puede aportar una vez que la tanda ha terminado', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    for (var i = 0; i < 3; i++) {
      _completarRonda(servicio);
    }
    expect(servicio.registrarAportacion('p1'), ResultadoAportacion.tandaTerminada);
  });

  // Extra: cerrar cuando ya terminó no debe romper
  test('cerrar la ronda cuando la tanda ya termino no lanza error', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    for (var i = 0; i < 3; i++) {
      _completarRonda(servicio);
    }
    final cierre = servicio.cerrarRondaYAvanzar();
    expect(cierre.resultado, ResultadoCierre.tandaYaTermino);
    expect(cierre.beneficiario, isNull);
  });

  // INTEGRACION
  test('simulacion completa: 3 vecinas completan una tanda de principio a fin', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    final beneficiarios = <String>[];
    while (!servicio.haTerminado()) {
      for (final p in tanda.participantes) {
        servicio.registrarAportacion(p.id);
      }
      final cierre = servicio.cerrarRondaYAvanzar();
      beneficiarios.add(cierre.beneficiario!.id);
    }
    expect(beneficiarios, ['p1', 'p2', 'p3']);
    expect(tanda.participantes.every((p) => p.yaRecibioTurno), true);
    expect(servicio.registrarAportacion('p1'), ResultadoAportacion.tandaTerminada);
  });
}
