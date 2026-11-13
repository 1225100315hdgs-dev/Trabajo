import 'dart:convert';

import 'package:directorio_dolores/datos/negocios_api.dart';
import 'package:directorio_dolores/dominio/negocio.dart';
import 'package:directorio_dolores/presentacion/negocios_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

NegociosViewModel vmCon(Future<http.Response> Function(http.Request) h) =>
    NegociosViewModel(NegociosApi(MockClient(h), 'http://prueba'));

void main() {
  test('cargar con datos termina en listo', () async {
    final vm = vmCon((_) async =>
        http.Response(jsonEncode([{'id': 1, 'nombre': 'A', 'categoria': 'X'}]), 200));
    final estados = <Estado>[];
    vm.addListener(() => estados.add(vm.estado));
    await vm.cargar();
    expect(estados, [Estado.cargando, Estado.listo]);
    expect(vm.negocios.length, 1);
  });

  test('cargar con lista vacía termina en vacio', () async {
    final vm = vmCon((_) async => http.Response('[]', 200));
    await vm.cargar();
    expect(vm.estado, Estado.vacio);
  });

  test('cargar con error de servidor termina en error con mensaje', () async {
    final vm = vmCon((_) async => http.Response('', 500));
    await vm.cargar();
    expect(vm.estado, Estado.error);
    expect(vm.mensajeError, contains('500'));
  });

  test('eliminar quita el negocio de la lista', () async {
    final vm = vmCon((req) async => req.method == 'DELETE'
        ? http.Response('', 204)
        : http.Response(
            jsonEncode([
              {'id': 1, 'nombre': 'A', 'categoria': 'X'},
              {'id': 2, 'nombre': 'B', 'categoria': 'Y'},
            ]),
            200));
    await vm.cargar();
    await vm.eliminar(vm.negocios.first);
    expect(vm.negocios.map((n) => n.id), [2]);
  });

  test('alternarFavorito actualiza con la respuesta del servidor', () async {
    final vm = vmCon((req) async {
      if (req.method == 'PUT') {
        return http.Response(
            jsonEncode({'id': 1, 'nombre': 'A', 'categoria': 'X', 'favorito': true}), 200);
      }
      return http.Response(jsonEncode([{'id': 1, 'nombre': 'A', 'categoria': 'X'}]), 200);
    });
    await vm.cargar();
    await vm.alternarFavorito(vm.negocios.first);
    expect(vm.negocios.first.favorito, true);
  });

  // RETO Ronda 5: si agregar() falla por un 400 → estado error con "400".
  test('agregar con 400 termina en error y el mensaje contiene 400', () async {
    final vm = vmCon((req) async => req.method == 'POST'
        ? http.Response(jsonEncode({'error': 'nombre y categoria son obligatorios'}), 400)
        : http.Response('[]', 200));
    await vm.agregar(const Negocio(nombre: '', categoria: ''));
    expect(vm.estado, Estado.error);
    expect(vm.mensajeError, contains('400'));
  });
}
