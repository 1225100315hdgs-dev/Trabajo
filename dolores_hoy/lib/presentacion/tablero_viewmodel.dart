import 'package:flutter/foundation.dart';

import '../datos/servicios.dart';
import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';

enum Estado { cargando, listo, error }

/// Estado de UNA tarjeta. Cada API tiene el suyo: si una falla, las demás viven.
class Carga<T> {
  final Estado estado;
  final T? dato;
  final String? error;
  const Carga._(this.estado, this.dato, this.error);
  const Carga.cargando() : this._(Estado.cargando, null, null);
  const Carga.listo(T dato) : this._(Estado.listo, dato, null);
  const Carga.fallo(String error) : this._(Estado.error, null, error);
}

class TableroViewModel extends ChangeNotifier {
  final ServicioClima _clima;
  final ServicioCambio _cambio;
  final ServicioFestivos _festivos;
  final ServicioWikipedia _wikipedia;
  final ServicioNasa _nasa;

  TableroViewModel({
    required ServicioClima clima,
    required ServicioCambio cambio,
    required ServicioFestivos festivos,
    required ServicioWikipedia wikipedia,
    required ServicioNasa nasa,
  })  : _clima = clima,
        _cambio = cambio,
        _festivos = festivos,
        _wikipedia = wikipedia,
        _nasa = nasa;

  Carga<Clima> clima = const Carga.cargando();
  Carga<TipoCambio> cambio = const Carga.cargando();
  Carga<List<Festivo>> festivos = const Carga.cargando();
  Carga<ResumenWiki> wiki = const Carga.cargando();
  Carga<FotoAstronomica> nasa = const Carga.cargando();

  /// Tema de Wikipedia que se está mostrando (RETO Ronda 6).
  String temaWiki = 'Dolores_Hidalgo';

  Future<void> cargarTodo() async {
    clima = const Carga.cargando();
    cambio = const Carga.cargando();
    festivos = const Carga.cargando();
    wiki = const Carga.cargando();
    nasa = const Carga.cargando();
    notifyListeners();

    // Las 5 peticiones salen al mismo tiempo (en paralelo).
    await Future.wait([
      _cargar(() => _clima.actual(), (c) => clima = c),
      _cargar(() => _cambio.deMxn(), (c) => cambio = c),
      _cargar(() => _festivos.proximos(), (c) => festivos = c),
      _cargar(() => _wikipedia.resumen(temaWiki), (c) => wiki = c),
      _cargar(() => _nasa.fotoDelDia(), (c) => nasa = c),
    ]);
  }

  /// RETO Ronda 6: el usuario escribe un tema. Solo se recarga la tarjeta de
  /// Wikipedia; las otras cuatro no se tocan.
  Future<void> buscarWiki(String tema) async {
    wiki = const Carga.cargando();
    notifyListeners();
    await _cargar(() => _wikipedia.resumen(tema), (c) => wiki = c);
    if (wiki.estado == Estado.listo) temaWiki = tema;
  }

  Future<void> _cargar<T>(Future<T> Function() pedir, void Function(Carga<T>) poner) async {
    try {
      poner(Carga.listo(await pedir()));
    } catch (e) {
      poner(Carga.fallo(mensajeSeguro(e)));
    }
    notifyListeners();
  }
}
