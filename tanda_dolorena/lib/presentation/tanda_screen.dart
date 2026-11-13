import 'package:flutter/material.dart';
import '../modelos/participante.dart';
import '../modelos/tanda.dart';
import '../logica/resultado_cierre.dart';
import '../logica/servicio_tanda.dart';

class TandaScreen extends StatefulWidget {
  const TandaScreen({super.key});

  @override
  State<TandaScreen> createState() => _TandaScreenState();
}

class _TandaScreenState extends State<TandaScreen> {
  late final Tanda _tanda;
  late final ServicioTanda _servicio;

  @override
  void initState() {
    super.initState();
    _tanda = Tanda(
      participantes: [
        Participante(id: 'p1', nombre: 'Ana'),
        Participante(id: 'p2', nombre: 'Beto'),
        Participante(id: 'p3', nombre: 'Carla'),
        Participante(id: 'p4', nombre: 'Diego'),
      ],
      ordenTurnos: ['p1', 'p2', 'p3', 'p4'],
      montoAportacion: 200,
    );
    _servicio = ServicioTanda(_tanda);
  }

  void _aportar(String idParticipante) {
    setState(() => _servicio.registrarAportacion(idParticipante));
  }

  void _cerrarRonda() {
    final cierre = _servicio.cerrarRondaYAvanzar();
    if (cierre.resultado == ResultadoCierre.faltanAportaciones) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todavia faltan vecinos por aportar.')),
      );
      return;
    }
    if (cierre.resultado == ResultadoCierre.tandaYaTermino) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La tanda ya termino.')),
      );
      return;
    }
    setState(() {});
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'beneficiario',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              title: const Text('Turno entregado'),
              content: Text('Le toco a ${cierre.beneficiario!.nombre} esta ronda!'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar')),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final terminada = _servicio.haTerminado();
    final totalAportado = _tanda.aportacionesRondaActual.length;
    final totalParticipantes = _tanda.participantes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Tanda Dolorena')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            terminada
                ? 'La tanda ha terminado'
                : 'Ronda actual: ${_tanda.turnoActual + 1} de ${_tanda.ordenTurnos.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(
                begin: 0,
                end: totalParticipantes == 0 ? 0 : totalAportado / totalParticipantes),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: valor, minHeight: 10),
            ),
          ),
          const SizedBox(height: 4),
          Text('$totalAportado de $totalParticipantes vecinos ya aportaron'),
          const SizedBox(height: 20),
          ..._tanda.participantes.map((participante) {
            final esTurnoActual =
                !terminada && _tanda.ordenTurnos[_tanda.turnoActual] == participante.id;
            final yaAporto =
                _tanda.aportacionesRondaActual.contains(participante.id);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esTurnoActual ? Colors.amber.shade100 : Colors.grey.shade100,
                border: Border.all(
                  color: esTurnoActual ? Colors.amber : Colors.grey.shade300,
                  width: esTurnoActual ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    participante.yaRecibioTurno ? Icons.check_circle : Icons.person,
                    color: participante.yaRecibioTurno ? Colors.green : Colors.indigo,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(participante.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (esTurnoActual)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text('Turno actual',
                          style: TextStyle(color: Colors.deepOrange, fontSize: 12)),
                    ),
                  OutlinedButton(
                    onPressed: (yaAporto || terminada) ? null : () => _aportar(participante.id),
                    child: Text(yaAporto ? 'Aporto' : 'Aportar'),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cerrarRonda,
            icon: const Icon(Icons.emoji_events),
            label: const Text('Cerrar ronda y entregar turno'),
          ),
        ],
      ),
    );
  }
}
