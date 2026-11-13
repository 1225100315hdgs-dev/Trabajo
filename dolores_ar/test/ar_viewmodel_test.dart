import 'dart:async';

import 'package:dolores_ar/dominio/excepciones.dart';
import 'package:dolores_ar/dominio/fuentes.dart';
import 'package:dolores_ar/dominio/geo.dart';
import 'package:dolores_ar/dominio/pasaporte.dart';
import 'package:dolores_ar/presentacion/ar_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_geo.dart';

class PosicionFalsa implements FuentePosicion {
  final c = StreamController<Coordenada>.broadcast();
  @override
  Stream<Coordenada> get posiciones => c.stream;
}

class BrujulaFalsa implements FuenteBrujula {
  final c = StreamController<double>.broadcast();
  @override
  Stream<double> get rumbos => c.stream;
}

void main() {
  late PosicionFalsa gps;
  late BrujulaFalsa brujula;
  late Pasaporte pasaporte;

  ArViewModel crear({double nortePlaza = 100}) {
    gps = PosicionFalsa();
    brujula = BrujulaFalsa();
    pasaporte = Pasaporte();
    final vm = ArViewModel(
      posicion: gps,
      brujula: brujula,
      lugares: [lugarEn('plaza', desplazar(origen, norte: nortePlaza))],
      pasaporte: pasaporte,
    );
    vm.iniciar();
    return vm;
  }

  test('mientras falte el GPS o la brújula, está esperando', () async {
    final vm = crear();
    expect(vm.esperando, true);
    gps.c.add(origen);
    await pumpEventQueue();
    expect(vm.esperando, true); // falta la brújula
    expect(vm.visibles, isEmpty);
    vm.dispose();
  });

  test('con GPS y brújula calcula qué lugares se ven', () async {
    final vm = crear();
    gps.c.add(origen);
    brujula.c.add(0);
    await pumpEventQueue();
    expect(vm.esperando, false);
    expect(vm.visibles.single.lugar.id, 'plaza');
    vm.dispose();
  });

  test('al girar la brújula se actualizan los visibles', () async {
    final vm = crear();
    gps.c.add(origen);
    brujula.c.add(0);
    await pumpEventQueue();
    expect(vm.visibles, hasLength(1));
    // Un giro grande: la brújula se suaviza, así que mandamos varias lecturas.
    for (var i = 0; i < 40; i++) {
      brujula.c.add(180);
    }
    await pumpEventQueue();
    expect(vm.visibles, isEmpty); // ahora miras hacia el sur
    vm.dispose();
  });

  test('la brújula se suaviza: un salto brusco no mueve todo de golpe', () async {
    final vm = crear();
    brujula.c.add(10);
    await pumpEventQueue();
    expect(vm.rumbo, 10); // la primera lectura se acepta tal cual
    brujula.c.add(350);
    await pumpEventQueue();
    expect(vm.rumbo, closeTo(6, 0.01)); // 10 + 0.2 × (-20)
    vm.dispose();
  });

  test('al acercarse a un lugar gana el sello una sola vez', () async {
    final vm = crear(nortePlaza: 20);
    gps.c.add(origen);
    brujula.c.add(0);
    await pumpEventQueue();
    expect(pasaporte.visitado('plaza'), true);
    expect(vm.consumirSello()?.id, 'plaza');
    expect(vm.consumirSello(), isNull); // ya se consumió
    gps.c.add(desplazar(origen, norte: 1)); // sigue cerca: no repite
    await pumpEventQueue();
    expect(vm.ultimoSello, isNull);
    vm.dispose();
  });

  test('un error de permiso se muestra con mensaje amable', () async {
    final vm = crear();
    gps.c.addError(const PermisoUbicacionException());
    await pumpEventQueue();
    expect(vm.error, contains('permiso'));
    vm.dispose();
  });

  test('un error desconocido NO filtra detalles internos', () async {
    final vm = crear();
    brujula.c.addError(StateError('fallo interno en /sensores/mag.dart'));
    await pumpEventQueue();
    expect(vm.error, isNot(contains('/sensores')));
    expect(vm.error, contains('inesperado'));
    vm.dispose();
  });

  test('notifica a la pantalla cada vez que algo cambia', () async {
    final vm = crear();
    var avisos = 0;
    vm.addListener(() => avisos++);
    gps.c.add(origen);
    brujula.c.add(0);
    await pumpEventQueue();
    expect(avisos, greaterThanOrEqualTo(2));
    vm.dispose();
  });
}
