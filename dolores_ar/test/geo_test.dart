import 'package:dolores_ar/dominio/catalogo.dart';
import 'package:dolores_ar/dominio/geo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_geo.dart';

void main() {
  group('distanciaMetros (Haversine)', () {
    test('un grado de latitud mide unos 111.2 km', () {
      expect(distanciaMetros(const Coordenada(0, 0), const Coordenada(1, 0)),
          closeTo(111195, 5));
    });
    test('el mismo punto está a 0 metros', () {
      expect(distanciaMetros(origen, origen), 0);
    });
    test('es simétrica: A→B = B→A', () {
      final b = desplazar(origen, norte: 300, este: 400);
      expect(distanciaMetros(origen, b), closeTo(distanciaMetros(b, origen), 0.001));
    });
    test('un punto a 300 m norte y 400 m este está a 500 m (triángulo 3-4-5)', () {
      final b = desplazar(origen, norte: 300, este: 400);
      expect(distanciaMetros(origen, b), closeTo(500, 1));
    });
    // RETO Ronda 1: Parroquia ↔ Plaza Principal entre 30 y 120 m.
    test('la Parroquia está entre 30 y 120 m de la Plaza Principal (catálogo)', () {
      final plaza = catalogoDolores.firstWhere((l) => l.id == 'plaza');
      final parroquia = catalogoDolores.firstWhere((l) => l.id == 'parroquia');
      final d = distanciaMetros(plaza.coordenada, parroquia.coordenada);
      expect(d, greaterThan(30));
      expect(d, lessThan(120));
    });
  });

  group('rumboGrados', () {
    test('norte = 0°', () => expect(rumboGrados(origen, desplazar(origen, norte: 100)), closeTo(0, 0.01)));
    test('este = 90°', () => expect(rumboGrados(origen, desplazar(origen, este: 100)), closeTo(90, 0.01)));
    test('sur = 180°', () => expect(rumboGrados(origen, desplazar(origen, norte: -100)), closeTo(180, 0.01)));
    test('oeste = 270°', () => expect(rumboGrados(origen, desplazar(origen, este: -100)), closeTo(270, 0.01)));
    test('noreste = 45°', () => expect(rumboGrados(origen, desplazar(origen, norte: 100, este: 100)), closeTo(45, 0.05)));
  });

  group('ángulos', () {
    test('normalizar360 lleva todo a 0..360', () {
      expect(normalizar360(-90), 270);
      expect(normalizar360(360), 0);
      expect(normalizar360(725), 5);
    });
    test('diferenciaAngular toma el camino corto', () {
      expect(diferenciaAngular(10, 350), 20); // gira 20° a la derecha
      expect(diferenciaAngular(350, 10), -20); // gira 20° a la izquierda
      expect(diferenciaAngular(90, 90), 0);
      expect(diferenciaAngular(181, 0), -179);
    });
    test('suavizarAngulo avanza una fracción hacia el nuevo valor', () {
      expect(suavizarAngulo(100, 110, alfa: 0.5), closeTo(105, 1e-9));
    });
    test('suavizarAngulo cruza el 0° por el lado corto (350° → 10°)', () {
      // Un promedio ingenuo daría 180°. El correcto da 0°.
      expect(suavizarAngulo(350, 10, alfa: 0.5), closeTo(0, 1e-9));
    });
    // RETO Ronda 2: nunca devuelve un valor fuera de 0-360.
    test('suavizarAngulo siempre devuelve un valor en 0..360', () {
      const entradas = [-720.0, -400.0, -90.0, -1.0, 0.0, 1.0, 359.0, 360.0, 400.0, 725.0, 1080.0];
      for (final a in entradas) {
        for (final b in entradas) {
          final r = suavizarAngulo(a, b);
          expect(r, greaterThanOrEqualTo(0), reason: 'a=$a b=$b');
          expect(r, lessThan(360), reason: 'a=$a b=$b');
        }
      }
    });
    test('nombreCardinal', () {
      expect(nombreCardinal(0), 'N');
      expect(nombreCardinal(44), 'NE');
      expect(nombreCardinal(90), 'E');
      expect(nombreCardinal(200), 'S');
      expect(nombreCardinal(270), 'O');
      expect(nombreCardinal(350), 'N');
    });
  });

  group('posicionHorizontal (campo de visión 60°)', () {
    test('justo al frente cae en el centro', () => expect(posicionHorizontal(0), 0.5));
    test('en el borde derecho', () => expect(posicionHorizontal(30), closeTo(1.0, 1e-9)));
    test('en el borde izquierdo', () => expect(posicionHorizontal(-30), closeTo(0.0, 1e-9)));
    test('a medio camino', () => expect(posicionHorizontal(15), closeTo(0.75, 1e-9)));
    test('fuera del campo de visión no se dibuja', () {
      expect(posicionHorizontal(31), isNull);
      expect(posicionHorizontal(-90), isNull);
    });
  });

  group('formatearDistancia', () {
    test('metros y kilómetros', () {
      expect(formatearDistancia(85.4), '85 m');
      expect(formatearDistancia(999.4), '999 m');
      expect(formatearDistancia(1260), '1.3 km');
    });
  });
}
