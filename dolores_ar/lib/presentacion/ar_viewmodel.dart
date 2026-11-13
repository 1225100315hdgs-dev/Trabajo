import 'dart:async';

import 'package:flutter/foundation.dart';

import '../dominio/excepciones.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/lugar.dart';
import '../dominio/motor_ar.dart';
import '../dominio/pasaporte.dart';

class ArViewModel extends ChangeNotifier {
  final FuentePosicion _posicion;
  final FuenteBrujula _brujula;
  final List<Lugar> lugares;
  final Pasaporte pasaporte;
  final double campoVision;
  final double radioMax;

  ArViewModel({
    required FuentePosicion posicion,
    required FuenteBrujula brujula,
    required this.lugares,
    required this.pasaporte,
    this.campoVision = 60,
    this.radioMax = 2000,
  })  : _posicion = posicion,
        _brujula = brujula;

  Coordenada? usuario;
  double? rumbo;
  List<LugarVisible> visibles = [];
  String? error;
  Lugar? ultimoSello;

  StreamSubscription<Coordenada>? _subPosicion;
  StreamSubscription<double>? _subBrujula;

  bool get esperando => usuario == null || rumbo == null;

  void iniciar() {
    _subPosicion = _posicion.posiciones.listen((p) {
      usuario = p;
      _recalcular();
    }, onError: _alFallar);

    _subBrujula = _brujula.rumbos.listen((g) {
      // El primer dato se toma tal cual; los siguientes se suavizan.
      rumbo = rumbo == null ? g : suavizarAngulo(rumbo!, g);
      _recalcular();
    }, onError: _alFallar);
  }

  void _alFallar(Object e) {
    error = mensajeSeguro(e);
    notifyListeners();
  }

  void _recalcular() {
    final u = usuario;
    final r = rumbo;
    if (u != null && r != null) {
      visibles = calcularVisibles(
        usuario: u,
        rumbo: r,
        lugares: lugares,
        campoVision: campoVision,
        radioMax: radioMax,
      );
      for (final l in lugares) {
        if (pasaporte.registrarSiCerca(l, distanciaMetros(u, l.coordenada))) {
          ultimoSello = l;
        }
      }
    }
    notifyListeners();
  }

  /// La pantalla llama esto para mostrar el aviso de sello una sola vez.
  Lugar? consumirSello() {
    final l = ultimoSello;
    ultimoSello = null;
    return l;
  }

  @override
  void dispose() {
    _subPosicion?.cancel();
    _subBrujula?.cancel();
    super.dispose();
  }
}
