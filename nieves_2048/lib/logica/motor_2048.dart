class ResultadoFusion {
  final List<int?> fila;
  final int puntosGanados;
  ResultadoFusion(this.fila, this.puntosGanados);
}

class ResultadoMovimiento {
  final List<int?> fila;
  final int puntosGanados;
  final bool seMovio;
  ResultadoMovimiento(this.fila, this.puntosGanados, this.seMovio);
}

class Motor2048 {
  /// Quita los huecos manteniendo el orden.
  static List<int?> compactarFila(List<int?> fila) {
    final valores = fila.where((v) => v != null).toList();
    while (valores.length < fila.length) {
      valores.add(null);
    }
    return valores;
  }

  /// Fusiona pares adyacentes iguales (una sola vez por ficha).
  static ResultadoFusion fusionarFila(List<int?> filaCompactada) {
    final resultado = List<int?>.from(filaCompactada);
    var puntos = 0;
    for (var i = 0; i < resultado.length - 1; i++) {
      if (resultado[i] != null && resultado[i] == resultado[i + 1]) {
        resultado[i] = resultado[i]! * 2;
        puntos += resultado[i]!;
        resultado[i + 1] = null;
      }
    }
    return ResultadoFusion(resultado, puntos);
  }

  static ResultadoMovimiento moverFilaIzquierda(List<int?> filaOriginal) {
    final compactada = compactarFila(filaOriginal);
    final fusion = fusionarFila(compactada);
    final filaFinal = compactarFila(fusion.fila);
    var seMovio = false;
    for (var i = 0; i < filaOriginal.length; i++) {
      if (filaOriginal[i] != filaFinal[i]) seMovio = true;
    }
    return ResultadoMovimiento(filaFinal, fusion.puntosGanados, seMovio);
  }
}
