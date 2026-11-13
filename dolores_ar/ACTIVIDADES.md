# Dolores AR — actividades realizadas

## Retos hechos en el código
| Reto del manual | Dónde quedó |
|---|---|
| Ronda 1: distancia Parroquia↔Plaza entre 30 y 120 m | `test/geo_test.dart` → prueba "la Parroquia está entre 30 y 120 m…" (el catálogo da ≈ 54 m: tiene sentido caminando, medio minuto a pie) |
| Ronda 2: `suavizarAngulo` nunca sale de 0–360 | `test/geo_test.dart` → prueba con negativos y mayores de 360 |
| Ronda 4: filtro `categorias` en el motor (prueba primero) | `lib/dominio/motor_ar.dart` (parámetro `categorias`) y grupo "filtro por categorías" en `test/motor_ar_test.dart` |
| Ronda 7: cambiar la posición demo | En `pantalla_inicio.dart`, `_irDemo`: cambia `Coordenada(21.15600, -100.93175)` por la del Museo José Alfredo Jiménez, `Coordenada(21.15520, -100.93260)` |
| Ronda 9.5: aviso de seguridad física | `pantalla_ar.dart`: SnackBar al iniciar |

Pendientes que requieren estar físicamente en Dolores Hidalgo o crear contenido propio: calibrar coordenadas (Ronda 9.1), calibrar brújula, y reemplazar el astronauta por tu propio .glb (Ronda 8).

## Preguntas para discutir en clase
**1. ¿Por qué la distancia entre dos puntos GPS no se calcula con Pitágoras?**
Porque la Tierra es (casi) una esfera y latitud/longitud no son metros sobre un plano. Un grado de longitud mide ~111 km en el ecuador, ~104 km en Dolores Hidalgo y casi 0 cerca del polo. Pitágoras sirve en una cuadra, pero en distancias largas el error crece (México–Madrid: cientos de km). Haversine mide la distancia por la superficie de la esfera.

**2. Miras a 350° y el lugar está a 15°. ¿Cuánto giras y hacia dónde? ¿Y si miras a 15° y el lugar está a 350°?**
`diferenciaAngular(15, 350)` = +25 → giras **25° a la derecha**. `diferenciaAngular(350, 15)` = −25 → giras **25° a la izquierda**. (Sin la corrección darías ±335°.)

**3. ¿Por qué suavizar con promedio normal produciría un bug al mirar al norte?**
Los ángulos forman un círculo: el promedio de 350° y 10° es 180° (sur), cuando lo correcto es 0° (norte). Las etiquetas saldrían disparadas al lado contrario cada vez que cruzas el norte. Por eso se promedia con la diferencia angular.

**4. ¿Qué ventaja tiene que el ViewModel dependa de `FuentePosicion` y no de `Geolocator`?**
Se puede probar con fuentes falsas (controlas cuándo llega una posición), hacer el modo demo sin GPS y cambiar de plugin o sensor sin tocar el ViewModel. Es como un enchufe estándar: a la lámpara no le importa si la luz viene de la CFE o de una batería.

**5. ¿Qué datos son sensibles? ¿Cómo se protegen?**
La ubicación (dice dónde vives, trabajas, estudias) y la imagen de la cámara. Protección: permiso mínimo ("solo mientras se usa la app"), cálculo dentro del teléfono sin enviarlo a servidores, guardar del pasaporte solo ids de lugares (no coordenadas), aviso de privacidad claro y consentimiento explícito si algún día hay servidor.

**6. ¿Qué pasaría si el campo de visión real fuera 80° y la app asume 60°?**
La posición se calcula con `0.5 + dif/60` en vez de `dif/80`: las etiquetas se separan más de lo real y se desplazan hacia los bordes (el error es 0 al centro y crece hacia los lados). Además los lugares entre ±30° y ±40° no se dibujan aunque se vean en la cámara. Solución: hacer `campoVision` configurable/calibrable (por eso es parámetro).
