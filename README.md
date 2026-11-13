# Proyectos TDD - Desarrollo Movil Integral

|@"
# Proyectos TDD - Desarrollo Móvil Integral

@"
# Proyectos

| Carpeta | Nombre del proyecto |
| :--- | :--- |
| **directorio_dolores** | Directorio Dolores |
| **dolores_ar** | Dolores AR |
| **dolores_hoy** | Dolores Hoy |
| **herramientas** | Herramientas |
| **nieves_2048** | Nieves 2048 |
| **punto_venta_dolores** | Punto de Venta Dolores |
| **tanda_dolorena** | Tanda Doloreña |
"@ | Out-File -FilePath README.md -Encoding utf8

## Primera vez (una sola vez)
    cd proyectos_tdd
    powershell -ExecutionPolicy Bypass -File .\preparar.ps1

## Correr las pruebas de los 3
    powershell -ExecutionPolicy Bypass -File .\probar_todo.ps1

## Correr las pruebas de uno solo
    cd tanda_dolorena
    flutter test

## Ejecutar una app (entrar primero a su carpeta)
    cd nieves_2048
    flutter run -d windows

Cambia nieves_2048 por tanda_dolorena o punto_venta_dolores.
Para ver dispositivos disponibles: flutter devices

## Manuales nuevos (dolores_ar, dolores_hoy, directorio_dolores)
Primera vez (genera android/ios, aplica permisos y baja paquetes):

    powershell -ExecutionPolicy Bypass -File .\preparar_manuales.ps1

Pruebas automaticas de los 3 (mas la API de Node):

    powershell -ExecutionPolicy Bypass -File .\probar_manuales.ps1

Como probar la funcionalidad de cada app a mano: ver GUIA_PRUEBAS.md.
Respuestas a las preguntas de clase y retos: ACTIVIDADES.md dentro de cada proyecto.
