// Prueba de funcionalidad automática de la API (RETO de la Ronda 1).
// Uso (con el servidor encendido en otra terminal):  node probar_api.js
// Otro puerto: PORT=3001 node probar_api.js   (Node 18+, usa fetch integrado)
const base = `http://localhost:${process.env.PORT || 3000}`;
let ok = 0, mal = 0;

function verificar(nombre, condicion, detalle = '') {
  if (condicion) { ok++; console.log(`  ✔ ${nombre}`); }
  else { mal++; console.log(`  ✘ ${nombre} ${detalle}`); }
}
const pedir = (ruta, opciones = {}) => fetch(base + ruta, opciones);
const json = { 'Content-Type': 'application/json' };

(async () => {
  try {
    console.log('Salud y lectura');
    let r = await pedir('/salud');
    verificar('GET /salud → 200 {ok:true}', r.status === 200 && (await r.json()).ok === true);

    r = await pedir('/negocios');
    const lista = await r.json();
    verificar('GET /negocios → 200 y es una lista', r.status === 200 && Array.isArray(lista));
    verificar('trae los 5 negocios iniciales', lista.length >= 5);

    r = await pedir('/negocios?q=' + encodeURIComponent('nieves'));
    const filtrada = await r.json();
    verificar('GET /negocios?q=nieves filtra por nombre', filtrada.length >= 1 && filtrada.every((n) => /nieves/i.test(n.nombre)));

    console.log('Errores esperados (RETO: 404 y 400)');
    r = await pedir('/negocios/99');
    verificar('GET /negocios/99 → 404', r.status === 404, `(recibió ${r.status})`);
    r = await pedir('/negocios', { method: 'POST', headers: json, body: JSON.stringify({ nombre: 'Sin categoría' }) });
    verificar('POST sin categoría → 400', r.status === 400, `(recibió ${r.status})`);
    r = await pedir('/negocios', { method: 'POST', headers: json, body: '{roto' });
    verificar('POST con JSON roto → 400', r.status === 400, `(recibió ${r.status})`);
    r = await pedir('/otra-ruta');
    verificar('ruta desconocida → 404', r.status === 404);

    console.log('Ciclo CRUD');
    r = await pedir('/negocios', { method: 'POST', headers: json, body: JSON.stringify({ nombre: 'Mi tienda', categoria: 'Abarrotes' }) });
    const nuevo = await r.json();
    verificar('POST → 201 con id asignado por el servidor', r.status === 201 && typeof nuevo.id === 'number');
    verificar('valores por omisión (telefono "", favorito false)', nuevo.telefono === '' && nuevo.favorito === false);

    r = await pedir(`/negocios/${nuevo.id}`);
    verificar('GET /negocios/ID → 200', r.status === 200 && (await r.json()).nombre === 'Mi tienda');

    r = await pedir(`/negocios/${nuevo.id}`, { method: 'PUT', headers: json, body: JSON.stringify({ favorito: true }) });
    const act = await r.json();
    verificar('PUT → 200 y cambia favorito', r.status === 200 && act.favorito === true && act.nombre === 'Mi tienda');
    r = await pedir('/negocios/9999', { method: 'PUT', headers: json, body: '{}' });
    verificar('PUT a un id inexistente → 404', r.status === 404);

    r = await pedir(`/negocios/${nuevo.id}`, { method: 'DELETE' });
    verificar('DELETE → 204', r.status === 204);
    r = await pedir(`/negocios/${nuevo.id}`);
    verificar('después de borrar, GET → 404', r.status === 404);
    r = await pedir(`/negocios/${nuevo.id}`, { method: 'DELETE' });
    verificar('borrar dos veces → 404', r.status === 404);

    r = await pedir('/negocios', { method: 'PATCH' });
    verificar('método no permitido → 405', r.status === 405);
  } catch (e) {
    mal++;
    console.log('  ✘ No se pudo conectar. ¿Está encendido el servidor (node server.js)?', e.cause?.code || e.message);
  }
  console.log(`\nResultado: ${ok} bien, ${mal} mal`);
  process.exit(mal === 0 ? 0 : 1);
})();
