// Parchea los archivos de plataforma que `flutter create .` genera, según lo que
// piden los manuales (permisos Android, minSdk, textos de iOS...). Es idempotente:
// puedes correrlo varias veces sin duplicar nada.
//
// Uso:  node herramientas/parchear.js <carpeta_del_proyecto> <dolores_ar|dolores_hoy|directorio>
const fs = require('fs');
const path = require('path');

const [, , carpeta, perfil] = process.argv;
if (!carpeta || !perfil) {
  console.error('Uso: node herramientas/parchear.js <carpeta> <dolores_ar|dolores_hoy|directorio>');
  process.exit(2);
}

const PERFILES = {
  dolores_ar: {
    permisos: [
      '<uses-permission android:name="android.permission.INTERNET"/>',
      '<uses-permission android:name="android.permission.CAMERA"/>',
      '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>',
      '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>',
      '<uses-feature android:name="android.hardware.camera" android:required="false"/>',
    ],
    // model_viewer_plus sirve el visor 3D por un servidor local http://localhost
    cleartext: true,
    minSdk: 24,
    plist: `\t<key>NSCameraUsageDescription</key>
\t<string>Usamos la cámara para mostrarte los lugares históricos a tu alrededor.</string>
\t<key>NSLocationWhenInUseUsageDescription</key>
\t<string>Usamos tu ubicación solo mientras la app está abierta, para saber qué lugares tienes cerca.</string>
`,
    plistClave: 'NSCameraUsageDescription',
  },
  dolores_hoy: {
    permisos: ['<uses-permission android:name="android.permission.INTERNET"/>'],
    cleartext: false, // TODAS las APIs usan https: que Android nos proteja de http por error
  },
  directorio: {
    permisos: ['<uses-permission android:name="android.permission.INTERNET"/>'],
    cleartext: true, // SOLO desarrollo: la API local usa http://
    plist: `\t<key>NSAppTransportSecurity</key>
\t<dict>
\t\t<key>NSAllowsLocalNetworking</key>
\t\t<true/>
\t</dict>
`,
    plistClave: 'NSAppTransportSecurity',
  },
};

const p = PERFILES[perfil];
if (!p) { console.error('Perfil desconocido: ' + perfil); process.exit(2); }

function leer(f) { return fs.existsSync(f) ? fs.readFileSync(f, 'utf8') : null; }
const cambios = [];

// ---- AndroidManifest.xml ----
const man = path.join(carpeta, 'android/app/src/main/AndroidManifest.xml');
let x = leer(man);
if (x === null) {
  console.log('(!) No existe ' + man + ' — ¿ya corriste "flutter create ."?');
} else {
  const faltan = p.permisos.filter((l) => !x.includes(l.match(/android:name="([^"]+)"/)[1]));
  if (faltan.length) {
    x = x.replace(/(\s*)<application/, (m, esp) =>
      faltan.map((l) => `${esp}${l.trim()}`).join('') + `${esp}<application`);
    cambios.push('permisos Android: ' + faltan.length);
  }
  if (p.cleartext && !x.includes('usesCleartextTraffic')) {
    x = x.replace('<application', '<application\n        android:usesCleartextTraffic="true"');
    cambios.push('usesCleartextTraffic');
  }
  fs.writeFileSync(man, x);
}

// ---- minSdk ----
if (p.minSdk) {
  for (const nombre of ['build.gradle.kts', 'build.gradle']) {
    const f = path.join(carpeta, 'android/app', nombre);
    let g = leer(f);
    if (g === null) continue;
    const nuevo = g
      .replace(/minSdk\s*=\s*flutter\.minSdkVersion/, `minSdk = ${p.minSdk}`)
      .replace(/minSdkVersion\s+flutter\.minSdkVersion/, `minSdkVersion ${p.minSdk}`);
    if (nuevo !== g) { fs.writeFileSync(f, nuevo); cambios.push(`minSdk ${p.minSdk}`); }
  }
}

// ---- iOS Info.plist ----
if (p.plist) {
  const f = path.join(carpeta, 'ios/Runner/Info.plist');
  let pl = leer(f);
  if (pl === null) {
    console.log('(i) Sin ios/Runner/Info.plist (normal si no generaste iOS).');
  } else if (!pl.includes(p.plistClave)) {
    pl = pl.replace(/<\/dict>\s*<\/plist>\s*$/, p.plist + '</dict>\n</plist>\n');
    fs.writeFileSync(f, pl);
    cambios.push('Info.plist');
  }
}

console.log(`[${perfil}] ` + (cambios.length ? 'parchado: ' + cambios.join(', ') : 'sin cambios (ya estaba listo)'));
