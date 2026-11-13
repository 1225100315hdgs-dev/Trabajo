# Dolores Hoy — actividades realizadas

## Retos hechos en el código
| Reto del manual | Dónde quedó |
|---|---|
| Ronda 6: caja de texto para el tema de Wikipedia | `pantalla_tablero.dart` (TextField + botón buscar) y `TableroViewModel.buscarWiki()`; pruebas en `test/tablero_viewmodel_test.dart` (grupo "buscarWiki") |
| Ronda 6: ¿qué mensaje ve con 100 letras? | "Dato inválido: tema demasiado largo" (y no se hace ninguna petición; hay prueba) |
| Ronda 7: probar `http://` | Experimento a mano: en un servicio cambia `Uri.https(...)` por `Uri.http(...)`. `ClienteSeguro` lanzará `ConexionInseguraException` ("Por seguridad solo se permiten direcciones https://") y la prueba de rechazo de http documenta esa defensa. Déjalo de nuevo en https. |
| Ronda 0/7: registrar tu clave NASA | Hazlo tú en api.nasa.gov y ponla en `secrets.json` (nunca en el chat ni en el repo) |

Corrección respecto al manual: `ClienteSeguro.redactar` arma el query manualmente. Con `uri.replace(queryParameters: ...)` Dart codifica `*` como `%2A` y la prueba `contains('api_key=***')` no se cumpliría.

## Preguntas para discutir en clase
**1. ¿Por qué `--dart-define` no basta para una clave que cuesta dinero? ¿Qué harías?**
La clave se compila dentro de la app instalada; un .apk es un .zip y con herramientas se puede encontrar. Solo evita que quede en el repositorio. Para claves de pago: proxy en tu propio servidor (la app llama a TU servidor y este guarda la clave), claves con mínimo privilegio y límite de uso, y rotación/revocación fácil.

**2. Un compañero sube su `secrets.json` a GitHub. ¿Qué pasos, en orden?**
(1) Revocar la clave de inmediato y generar una nueva. (2) Guardar la nueva solo en `secrets.json` local. (3) Quitar el archivo del repo y confirmar que `.gitignore` lo cubre (`git status` limpio). (4) Opcional: limpiar el historial (git filter-repo/BFG), sabiendo que la clave vieja ya debe darse por comprometida. (5) Revisar en el panel del proveedor si hubo uso indebido. (6) Avisar al equipo.

**3. ¿Qué ventaja tiene que todas las APIs pasen por `ClienteSeguro`?**
Las defensas (https, timeout, límite de tamaño, JSON validado, errores traducidos) viven en un solo lugar: se escriben y se prueban una vez, son consistentes en las 5 APIs y un cambio de política se hace en un único sitio.

**4. ¿Por qué validar la respuesta del servidor si "la NASA es confiable"?**
Porque la red no lo es (Wi-Fi cautivo que devuelve HTML, servidor comprometido, cambio de formato, URLs raras como `javascript:`). La validación de salida es defensa en profundidad: nunca confiar en lo que llega de internet.

**5. Si Wikipedia cambia el campo `extract`, ¿qué ve el usuario? ¿Qué prueba avisa primero?**
`ResumenWiki.desdeJson` falla al convertir, `convertir()` lo transforma en `RespuestaInvalidaException` y la tarjeta de Wikipedia muestra "El servidor respondió con datos que no entiendo."; las otras cuatro siguen funcionando. Ojo: las pruebas con `MockClient` usan el JSON que nosotros escribimos, así que seguirían en verde hasta actualizar ese JSON simulado; el aviso temprano real es abrir la URL en el navegador antes de clase (como pide el manual) y tener una prueba "si falta `extract` lanza RespuestaInvalida" (análoga a la del bloque `current` del clima).
