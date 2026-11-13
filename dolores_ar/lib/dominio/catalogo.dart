import 'geo.dart';
import 'lugar.dart';

/// COORDENADAS APROXIMADAS, de práctica.
/// Tarea en campo: párate en cada lugar, lee tus coordenadas en la pantalla
/// de diagnóstico y corrige estos valores (ver Ronda 9 del manual).
const catalogoDolores = <Lugar>[
  Lugar(
    id: 'plaza',
    nombre: 'Jardín Principal',
    emoji: '🌳',
    categoria: Categoria.plaza,
    descripcion: 'El corazón de la ciudad: kioscos, árboles, vendedores y el ambiente de siempre.',
    datoCurioso: 'Aquí se reúnen familias cada tarde, y alrededor se venden las famosas nieves.',
    coordenada: Coordenada(21.15610, -100.93180),
  ),
  Lugar(
    id: 'parroquia',
    nombre: 'Parroquia de Nuestra Señora de los Dolores',
    emoji: '⛪',
    categoria: Categoria.historia,
    descripcion: 'Templo donde el cura Miguel Hidalgo convocó al pueblo en la madrugada del 16 de septiembre de 1810.',
    datoCurioso: 'Se le conoce como la Cuna de la Independencia Nacional.',
    coordenada: Coordenada(21.15650, -100.93150),
  ),
  Lugar(
    id: 'casa_visita',
    nombre: 'Museo Casa de Visita',
    emoji: '🏠',
    categoria: Categoria.museo,
    descripcion: 'Antigua residencia de Miguel Hidalgo, hoy museo sobre su vida y los inicios del movimiento.',
    datoCurioso: 'Es una de las casas más importantes de la historia de México.',
    coordenada: Coordenada(21.15590, -100.93085),
  ),
  Lugar(
    id: 'museo_independencia',
    nombre: 'Museo de la Independencia Nacional',
    emoji: '🏛️',
    categoria: Categoria.museo,
    descripcion: 'Exhibe documentos y objetos que cuentan cómo empezó la lucha de Independencia.',
    datoCurioso: 'Ocupa un edificio histórico que antes tuvo otros usos.',
    coordenada: Coordenada(21.15700, -100.93230),
  ),
  Lugar(
    id: 'museo_jaj',
    nombre: 'Museo José Alfredo Jiménez',
    emoji: '🎺',
    categoria: Categoria.musica,
    descripcion: 'Homenaje al cantautor dolorense autor de "El Rey" y "Si nos dejan".',
    datoCurioso: 'José Alfredo Jiménez nació en Dolores Hidalgo en 1926.',
    coordenada: Coordenada(21.15520, -100.93260),
  ),
  Lugar(
    id: 'nieves',
    nombre: 'Nieves del Jardín',
    emoji: '🍦',
    categoria: Categoria.gastronomia,
    descripcion: 'Puestos de nieves de sabores sorprendentes: aguacate, tequila, elote, camarón...',
    datoCurioso: 'Probar una nieve "atrevida" es casi una tradición para los visitantes.',
    coordenada: Coordenada(21.15605, -100.93165),
  ),
  Lugar(
    id: 'tumba_jaj',
    nombre: 'Tumba de José Alfredo Jiménez',
    emoji: '🌹',
    categoria: Categoria.musica,
    descripcion: 'Lugar de descanso del compositor, visitado por admiradores de todo el país.',
    datoCurioso: 'Muchos visitantes dejan flores o canciones en su memoria.',
    coordenada: Coordenada(21.14980, -100.92700),
  ),
];
