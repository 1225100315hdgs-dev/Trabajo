import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// AR de superficie: el visitante coloca un modelo 3D sobre el piso o una mesa.
/// En Android abre Scene Viewer (ARCore); en iPhone, Quick Look (necesita .usdz).
class PantallaModelo3D extends StatelessWidget {
  /// Modelo de práctica (astronauta). Cámbialo por TU modelo, por ejemplo una
  /// campana o el monumento a Hidalgo creado con fotogrametría:
  /// src: 'assets/modelos/campana.glb' (y decláralo en pubspec.yaml)
  static const modeloDePractica =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  const PantallaModelo3D({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modelo 3D en tu espacio')),
      body: const ModelViewer(
        src: modeloDePractica,
        alt: 'Modelo 3D de práctica',
        ar: true,
        arModes: ['scene-viewer', 'webxr', 'quick-look'],
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }
}
