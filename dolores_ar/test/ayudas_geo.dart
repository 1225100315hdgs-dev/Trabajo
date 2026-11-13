// Ayudas compartidas por las pruebas (no es una prueba en sí).
import 'dart:math' as math;

import 'package:dolores_ar/dominio/geo.dart';
import 'package:dolores_ar/dominio/lugar.dart';

const origen = Coordenada(21.1561, -100.9318);

/// Mueve un punto [norte] metros hacia el norte y [este] metros hacia el este.
Coordenada desplazar(Coordenada c, {double norte = 0, double este = 0}) {
  const metrosPorGrado = 111194.93;
  return Coordenada(
    c.lat + norte / metrosPorGrado,
    c.lon + este / (metrosPorGrado * math.cos(c.lat * math.pi / 180)),
  );
}

Lugar lugarEn(String id, Coordenada c, {Categoria categoria = Categoria.plaza}) => Lugar(
      id: id,
      nombre: id,
      emoji: '📍',
      categoria: categoria,
      descripcion: '',
      datoCurioso: '',
      coordenada: c,
    );
