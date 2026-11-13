import 'package:dolores_hoy/datos/config_claves.dart';
import 'package:dolores_hoy/datos/servicios.dart';
import 'package:dolores_hoy/presentacion/tablero_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'ayudas.dart';

TableroViewModel crear(Future<http.Response> Function(http.Request) h) {
  final c = seguro(h);
  return TableroViewModel(
    clima: ServicioClima(c),
    cambio: ServicioCambio(c),
    festivos: ServicioFestivos(c),
    wikipedia: ServicioWikipedia(c),
    nasa: ServicioNasa(c, const ConfigClaves(nasa: 'DEMO_KEY')),
  );
}

void main() {
  test('las 5 tarjetas cargan correctamente', () async {
    final vm = crear(servidorFalso);
    await vm.cargarTodo();
    expect(vm.clima.estado, Estado.listo);
    expect(vm.cambio.estado, Estado.listo);
    expect(vm.festivos.estado, Estado.listo);
    expect(vm.wiki.estado, Estado.listo);
    expect(vm.nasa.estado, Estado.listo);
    expect(vm.clima.dato!.temperatura, 24.3);
  });

    test('si UNA api falla, las otras cuatro siguen funcionando', () async {
    final vm = crear((r) async {
      if (r.url.host == 'api.nasa.gov') return jsonOk({}, 500);
      return await servidorFalso(r);
    });
    await vm.cargarTodo();
    expect(vm.nasa.estado, Estado.error);
    expect(vm.nasa.error, contains('500'));
    expect(vm.clima.estado, Estado.listo);
    expect(vm.cambio.estado, Estado.listo);
    expect(vm.wiki.estado, Estado.listo);
  });

  test('sin internet, todas muestran error pero la app no se cae', () async {
    final vm = crear((_) async => throw Exception('sin red'));
    await vm.cargarTodo();
    for (final e in [
      vm.clima.estado,
      vm.cambio.estado,
      vm.festivos.estado,
      vm.wiki.estado,
      vm.nasa.estado
    ]) {
      expect(e, Estado.error);
    }
    // El mensaje es genérico: no revela el texto interno del error.
    expect(vm.clima.error, isNot(contains('sin red')));
  });

  test('cargarTodo anuncia el estado cargando antes de terminar', () async {
    final vm = crear(servidorFalso);
    final vistos = <Estado>[];
    vm.addListener(() => vistos.add(vm.clima.estado));
    await vm.cargarTodo();
    expect(vistos.first, Estado.cargando);
    expect(vistos.last, Estado.listo);
  });

  // RETO Ronda 6: tema escrito por el usuario.
  group('buscarWiki (tema del usuario)', () {
    test('un tema válido pide ese tema y solo cambia la tarjeta de Wikipedia', () async {
      String? ultimoSegmento;
      final vm = crear((r) async {
        if (r.url.host == 'es.wikipedia.org') ultimoSegmento = r.url.pathSegments.last;
        return servidorFalso(r);
      });
      await vm.cargarTodo();
      final climaAntes = vm.clima;
      await vm.buscarWiki('Talavera de la Reina');
      expect(ultimoSegmento, 'Talavera_de_la_Reina');
      expect(vm.wiki.estado, Estado.listo);
      expect(identical(vm.clima, climaAntes), true); // las demás no se tocaron
    });

    test('100 letras muestran un mensaje amable, sin llamar a la red', () async {
      var llamadasWiki = 0;
      final vm = crear((r) async {
        if (r.url.host == 'es.wikipedia.org') llamadasWiki++;
        return servidorFalso(r);
      });
      await vm.buscarWiki('a' * 100);
      expect(vm.wiki.estado, Estado.error);
      expect(vm.wiki.error, contains('demasiado largo'));
      expect(llamadasWiki, 0);
    });

    test('un tema vacío muestra error y no rompe las demás', () async {
      final vm = crear(servidorFalso);
      await vm.cargarTodo();
      await vm.buscarWiki('   ');
      expect(vm.wiki.estado, Estado.error);
      expect(vm.clima.estado, Estado.listo);
    });
  });
}
