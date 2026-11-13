# Directorio Dolorense — actividades realizadas

## Retos hechos
| Reto del manual | Dónde quedó |
|---|---|
| Ronda 1: GET /negocios/99 y POST sin categoría con `curl -i` | `api/probar_api.js` los verifica solos: **404** y **400** (coinciden con la tabla de códigos). A mano: `curl.exe -i localhost:3000/negocios/99` |
| Ronda 3: prueba de `actualizar()` (PUT) | `app/test/negocios_api_test.dart` → "actualizar usa PUT, la ruta /negocios/ID y manda favorito en el body" |
| Ronda 5: `agregar()` con 400 → estado error con "400" | `app/test/viewmodel_test.dart` → "agregar con 400 termina en error…" |

## Preguntas para discutir en clase
**1. ¿Por qué inyectamos el `http.Client` en vez de crearlo dentro de `NegociosApi`?**
Para poder pasarle un `MockClient` en las pruebas (respuestas exactas, sin red ni servidor, en milisegundos) y para cambiar o decorar el cliente (logs, timeouts) sin tocar la clase.

**2. ¿Qué ventaja tiene que la API devuelva 201 al crear en vez de 200?**
201 significa "Creado": el cliente distingue una creación de una simple lectura/actualización y respeta el estándar REST; además documenta que el servidor asignó un recurso nuevo (con su id).

**3. ¿Qué pasaría si dos celulares borran el mismo negocio al mismo tiempo?**
El primero recibe 204; el segundo, 404 ("No existe"). Con el código actual el segundo celular pasa a estado error ("No se encontró lo que buscabas (404)"). Mejora: tratar el 404 de un DELETE como éxito (la operación es idempotente: el negocio ya no está) o recargar la lista.

**4. ¿Qué cambiaría si mañana la API fuera un servidor real con HTTPS?**
Solo la URL base (`https://…`) vía `--dart-define=API_URL`; se quita `usesCleartextTraffic` y `NSAllowsLocalNetworking`; ya no se usa 10.0.2.2 ni IP local; conviene agregar autenticación (token en `Authorization`), revisar CORS/certificados y manejar 401/403. `NegociosApi`, el modelo y el ViewModel casi no cambian.
