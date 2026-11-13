import 'package:flutter/material.dart';

import '../dominio/geo.dart';
import '../dominio/lugar.dart';
import '../dominio/motor_ar.dart';
import 'ar_viewmodel.dart';
import 'fondo_camara.dart';

class PantallaAr extends StatefulWidget {
  /// Se recibe una "fábrica": el State crea el ViewModel UNA sola vez y es
  /// dueño de él (así Flutter puede reconstruir la ruta sin duplicarlo).
  final ArViewModel Function() crearVm;
  final Widget? controlesDemo; // el modo demo agrega aquí su deslizador

  const PantallaAr({super.key, required this.crearVm, this.controlesDemo});

  @override
  State<PantallaAr> createState() => _PantallaArState();
}

class _PantallaArState extends State<PantallaAr> {
  late final ArViewModel vm = widget.crearVm();

  @override
  void initState() {
    super.initState();
    vm.addListener(_avisarSello);
    vm.iniciar();
    // Seguridad física (Ronda 9.5): aviso al iniciar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mira a tu alrededor, cuida tu paso y no cruces la calle viendo el teléfono.'),
        duration: Duration(seconds: 5),
      ));
    });
  }

  void _avisarSello() {
    final sello = vm.consumirSello();
    if (sello != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🏅 ¡Sello conseguido: ${sello.nombre}!')),
      );
    }
  }

  @override
  void dispose() {
    vm.removeListener(_avisarSello);
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) => Stack(fit: StackFit.expand, children: [
          const FondoCamara(),
          LayoutBuilder(
              builder: (_, caja) => Stack(children: [
                    for (final v in vm.visibles) _etiqueta(context, v, caja),
                  ])),
          SafeArea(child: _panelSuperior(vm)),
          if (widget.controlesDemo != null)
            Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(child: widget.controlesDemo!)),
        ]),
      ),
    );
  }

  Widget _panelSuperior(ArViewModel vm) {
    final texto = vm.error ??
        (vm.esperando
            ? 'Buscando GPS y brújula…'
            : '${nombreCardinal(vm.rumbo!)} ${vm.rumbo!.round()}° · '
                '${vm.visibles.length} lugares · ${vm.pasaporte.total}/${vm.lugares.length}');
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: vm.error != null ? Colors.red.shade800 : Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(texto, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _etiqueta(BuildContext context, LugarVisible v, BoxConstraints caja) {
    const ancho = 150.0;
    // Pseudo-perspectiva: lo lejano "sube" hacia el horizonte, lo cercano baja.
    final top = caja.maxHeight * (0.55 - 0.30 * v.profundidad);
    return Positioned(
      left: v.x * caja.maxWidth - ancho / 2,
      top: top,
      width: ancho,
      child: Transform.scale(
        scale: v.escala,
        child: GestureDetector(
          onTap: () => _detalle(context, v),
          child: Card(
            color: Colors.white.withAlpha(235),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(v.lugar.emoji, style: const TextStyle(fontSize: 26)),
                Text(v.lugar.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                Text(formatearDistancia(v.distancia),
                    style: const TextStyle(fontSize: 11, color: Colors.black87)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _detalle(BuildContext context, LugarVisible v) {
    final Lugar l = v.lugar;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l.emoji} ${l.nombre}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('A ${formatearDistancia(v.distancia)} de ti',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Text(l.descripcion),
              const SizedBox(height: 12),
              Text('💡 ${l.datoCurioso}'),
              const SizedBox(height: 8),
            ]),
      ),
    );
  }
}
