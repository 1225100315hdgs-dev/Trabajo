import 'package:dolores_ar/dominio/lugar.dart';
import 'package:dolores_ar/dominio/motor_ar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_geo.dart';

void main() {
  final frente = lugarEn('frente', desplazar(origen, norte: 100));
  final derecha = lugarEn('derecha', desplazar(origen, este: 100));
  final lejos = lugarEn('lejos', desplazar(origen, norte: 5000));

  test('un lugar justo adelante aparece en el centro de la pantalla', () {
    final r = calcularVisibles(usuario: origen, rumbo: 0, lugares: [frente]);
    expect(r.single.x, closeTo(0.5, 0.01));
    expect(r.single.distancia, closeTo(100, 1));
  });

  test('un lugar a 90° a la derecha NO aparece si miras al norte', () {
    final r = calcularVisibles(usuario: origen, rumbo: 0, lugares: [derecha]);
    expect(r, isEmpty);
  });

  test('al girar hacia el este, ese lugar aparece en el centro', () {
    final r = calcularVisibles(usuario: origen, rumbo: 90, lugares: [derecha]);
    expect(r.single.x, closeTo(0.5, 0.01));
  });

  test('si giras un poco, el lugar se desplaza al lado contrario', () {
    // Miras 10° a la derecha del norte: el lugar queda a TU izquierda.
    final r = calcularVisibles(usuario: origen, rumbo: 10, lugares: [frente]);
    expect(r.single.x, lessThan(0.5));
  });

  test('lugares más allá del radio máximo se descartan', () {
    final r = calcularVisibles(usuario: origen, rumbo: 0, lugares: [lejos], radioMax: 2000);
    expect(r, isEmpty);
  });

  test('funciona al cruzar el 0°/360° (miras a 350° y el lugar está a 5°)', () {
    final casi = lugarEn('casi', desplazar(origen, norte: 100, este: 8.7)); // ≈ 5°
    final r = calcularVisibles(usuario: origen, rumbo: 350, lugares: [casi]);
    expect(r, hasLength(1));
    expect(r.single.x, greaterThan(0.5)); // queda a la derecha
  });

  test('los lejanos van primero para dibujarse debajo de los cercanos', () {
    final cerca = lugarEn('cerca', desplazar(origen, norte: 50));
    final media = lugarEn('media', desplazar(origen, norte: 500));
    final r = calcularVisibles(usuario: origen, rumbo: 0, lugares: [cerca, media]);
    expect(r.map((v) => v.lugar.id), ['media', 'cerca']);
  });

  test('lo cercano se ve más grande que lo lejano', () {
    final cerca = lugarEn('cerca', desplazar(origen, norte: 50));
    final media = lugarEn('media', desplazar(origen, norte: 1500));
    final r = calcularVisibles(usuario: origen, rumbo: 0, lugares: [cerca, media]);
    final vCerca = r.firstWhere((v) => v.lugar.id == 'cerca');
    final vLejos = r.firstWhere((v) => v.lugar.id == 'media');
    expect(vCerca.escala, greaterThan(vLejos.escala));
    expect(vCerca.profundidad, lessThan(vLejos.profundidad));
  });

  test('un campo de visión más ancho muestra más lugares', () {
    final lado = lugarEn('lado', desplazar(origen, norte: 100, este: 80)); // ≈ 39°
    expect(calcularVisibles(usuario: origen, rumbo: 0, lugares: [lado], campoVision: 60), isEmpty);
    expect(calcularVisibles(usuario: origen, rumbo: 0, lugares: [lado], campoVision: 100), hasLength(1));
  });

  // RETO Ronda 4: filtro por categorías (prueba escrita primero).
  group('filtro por categorías', () {
    final museo = lugarEn('museo', desplazar(origen, norte: 100), categoria: Categoria.museo);
    final plaza = lugarEn('plaza', desplazar(origen, norte: 120), categoria: Categoria.plaza);

    test('solo museos', () {
      final r = calcularVisibles(
          usuario: origen, rumbo: 0, lugares: [museo, plaza], categorias: {Categoria.museo});
      expect(r.map((v) => v.lugar.id), ['museo']);
    });
    test('sin filtro (null) o vacío muestra todo', () {
      expect(calcularVisibles(usuario: origen, rumbo: 0, lugares: [museo, plaza]), hasLength(2));
      expect(
          calcularVisibles(usuario: origen, rumbo: 0, lugares: [museo, plaza], categorias: {}),
          hasLength(2));
    });
    test('varias categorías a la vez', () {
      final r = calcularVisibles(
          usuario: origen,
          rumbo: 0,
          lugares: [museo, plaza],
          categorias: {Categoria.museo, Categoria.plaza});
      expect(r, hasLength(2));
    });
  });
}
