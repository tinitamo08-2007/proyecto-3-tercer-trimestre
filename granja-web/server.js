// =======================================================
// SERVIDOR GESTIÓN DE GRANJA
// =======================================================
// servidor web con Node.js y Express muestra
// datos de animales, empleados y actividades diarias. Está
// preparado para conectarse a la base de datos mysql, pero si la conexión falla o la base
// no está disponible, utiliza automáticamente unos datos
// de demostración, para que el panel siempre funcione.
// =======================================================

//  IMPORTACIONES 
// express: framework para crear el servidor y las rutas.
// mysql2:  controlador para conectar con MySQL.
// path:    ayuda a construir rutas de archivos en el disco.
const express = require('express');
const mysql   = require('mysql2');
const path    = require('path');

// CONFIGURACIÓN EXPRESS 
const app  = express();          // Creamos la aplicación
const PORT = 3000;               // Puerto en el que se escuchará

// Middlewares: funciones que se ejecutan en cada petición
// para interpretar los datos que llegan.
// express.json() permite recibir JSON en el cuerpo de las peticiones.
// express.urlencoded({extended:true}) interpreta datos de formularios HTML.
// express.static('public') sirve directamente los archivos de la carpeta

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// INTENTO DE CONEXIÓN A LA BASE DE DATOS MYSQL (AIVEN) 
// La base de datos se llama 'granja' y está alojada en la nube.
// Es necesario haber ejecutado antes el script de creación de tablas
// (script_creacion_aiven.sql) para que las tablas existan.
const conexion = mysql.createConnection({
    host:     'granja-mysql-granjamysql.j.aivencloud.com',
    user:     'avnadmin',
    port:     '18071',
    password: '(AQUI_VA_LA_CONTRASEÑA_REAL)',  
    database: 'granja',
});

// Verificamos si la conexión fue exitosa.
// Si falla, mostraremos un mensaje y el sistema recurrirá a los datos DEMO.
conexion.connect((err) => {
    if (err) {
        console.log('Sin conexión a MySQL, usando datos de demo.');
    } else {
        console.log('Conectado a MySQL correctamente.');
    }
});

// DATOS DE DEMOSTRACIÓN
// Estos datos imitan exactamente la estructura y los valores
// que devolverían las consultas SQL.
const DEMO = {
    animales: [
        { id:1, especie:'vaca',    raza:'Holstein',         identificador:'ARETE-001', estado_salud:'buena',   ubicacion:'Corral 1' },
        { id:2, especie:'vaca',    raza:'Pirenaica',        identificador:'ARETE-002', estado_salud:'buena',   ubicacion:'Corral 1' },
        { id:3, especie:'vaca',    raza:'Holstein',         identificador:'ARETE-003', estado_salud:'regular', ubicacion:'Corral 2' },
        { id:4, especie:'oveja',   raza:'Merina',           identificador:'ARETE-101', estado_salud:'buena',   ubicacion:'Potrero Norte' },
        { id:5, especie:'oveja',   raza:'Latxa',            identificador:'ARETE-102', estado_salud:'grave',   ubicacion:'Enfermeria' },
        { id:6, especie:'cerdo',   raza:'Duroc',            identificador:'CHIP-201',  estado_salud:'buena',   ubicacion:'Corral 3' },
        { id:7, especie:'gallina', raza:'Castellana negra', identificador:'ANILLA-301',estado_salud:'buena',   ubicacion:'Gallinero' },
    ],
    empleados: [
        { id:1, nombre:'Maria Lopez',     rol:'veterinario', telefono:'666111222', fecha_contratacion:'2022-04-15' },
        { id:2, nombre:'Juan Perez',      rol:'peon',        telefono:'655234567', fecha_contratacion:'2023-09-01' },
        { id:3, nombre:'Lucia Fernandez', rol:'encargado',   telefono:'644555888', fecha_contratacion:'2021-01-10' },
        { id:4, nombre:'Carlos Romero',   rol:'peon',        telefono:'633998877', fecha_contratacion:'2024-02-20' },
        { id:5, nombre:'Sofia Ruiz',      rol:'veterinario', telefono:'611222333', fecha_contratacion:'2023-06-01' },
    ],
    actividades: [
        { id:1, fecha:'2026-05-10', hora:'06:30', tipo:'ORDENIE',      empleado:'Juan Perez',    animales:'ARETE-001, ARETE-002' },
        { id:2, fecha:'2026-05-10', hora:'08:00', tipo:'ALIMENTACION', empleado:'Juan Perez',    animales:'ARETE-001, ARETE-002, ARETE-003' },
        { id:3, fecha:'2026-05-10', hora:'10:15', tipo:'VACUNACION',   empleado:'Maria Lopez',   animales:'ARETE-102' },
        { id:4, fecha:'2026-05-10', hora:'17:30', tipo:'LIMPIEZA',     empleado:'Carlos Romero', animales:'ANILLA-301' },
        { id:5, fecha:'2026-05-11', hora:'06:30', tipo:'ORDENIE',      empleado:'Juan Perez',    animales:'ARETE-001, ARETE-002' },
    ],
};

// FUNCIÓN AUXILIAR PARA CONSULTAS SQL 
// Centraliza la ejecución de cualquier consulta, captura errores
// y llama a un callback con los resultados o con null si falló.

function hacerConsulta(sql, params, callback) {
    conexion.query(sql, params, (error, resultados) => {
        if (error) {
            console.log('Error en la consulta:', error.message);
            callback(null);                 
        } else {
            callback(resultados);          
        }
    });
}

// RUTAS DE LA API

// OBTENER LISTADOS COMPLETOS 
// Cada una de estas rutas intenta recuperar todos los registros
// de su tabla correspondiente. Si la base responde,
// envía los datos reales y la propiedad 'demo' en false.
// Si falla, envía los datos de demostración y 'demo' en true.
// Así el panel siempre tiene información que mostrar.

app.get('/api/animales', (req, res) => {
    hacerConsulta('SELECT * FROM animal', [], (datos) => {
        res.json({
            data: datos || DEMO.animales,
            demo: !datos                     
        });
    });
});

app.get('/api/empleados', (req, res) => {
    hacerConsulta('SELECT * FROM empleado', [], (datos) => {
        res.json({
            data: datos || DEMO.empleados,
            demo: !datos
        });
    });
});

app.get('/api/actividades', (req, res) => {
    // En lugar de consultar la tabla directamente, usamos una vista
    // llamada 'vista_actividades' que ya hace los JOIN con empleado
    // y animal, mostrando la información de forma más legible.
    hacerConsulta('SELECT * FROM vista_actividades', [], (datos) => {
        res.json({
            data: datos || DEMO.actividades,
            demo: !datos
        });
    });
});

// CONSULTAS FILTRADAS DESDE EL FORMULARIO WEB 
// Esta ruta POST recibe un JSON con un 'tipo' de filtro y un 'filtro'
// con el valor a buscar.
// Si la base no funciona, filtra entre los datos DEMO según el tipo.

app.post('/api/consulta', (req, res) => {
    const tipo   = req.body.tipo;      
    const filtro = req.body.filtro;    

    // Validación: el campo 'tipo' es obligatorio
    if (!tipo) {
        return res.status(400).json({
            error: 'Falta el campo tipo',
            ejemplo: '{ "tipo": "animales_especie", "filtro": "vaca" }'
        });
    }

    // tipos de consulta permitidos a las sentencias SQL correspondientes
    const consultas = {
        animales_especie:  "SELECT * FROM animal     WHERE especie      LIKE CONCAT('%', ?, '%')",
        empleados_rol:     "SELECT * FROM empleado   WHERE rol          LIKE CONCAT('%', ?, '%')",
        actividades_fecha: "SELECT * FROM vista_actividades WHERE fecha LIKE CONCAT('%', ?, '%')",
        animales_salud:    "SELECT * FROM animal     WHERE estado_salud LIKE CONCAT('%', ?, '%')",
    };

    // Si el tipo no está en la lista, devolvemos un error 400
    if (!consultas[tipo]) {
        return res.status(400).json({
            error: 'Tipo de consulta no válido',
            tiposPermitidos: Object.keys(consultas)
        });
    }

    // Ejecutamos la consulta correspondiente, pasando el filtro como parámetro
    hacerConsulta(consultas[tipo], [filtro || ''], (datos) => {
        // Si no hay datos usamos DEMO filtrando manualmente
        // la categoría base (animales, empleados o actividades)
        const categoria = datos ? null : DEMO[tipo.split('_')[0]]; // ej: 'animales', 'empleados'...
        res.json({
            data:     datos || categoria,
            demo:     !datos,
            total:    datos ? datos.length : (categoria ? categoria.length : 0),
            consulta: tipo.replace('_', ' por ')   
        });
    });
});

// ESTADÍSTICAS GENERALES 
// Devuelve cuatro números: total de animales, total de animales sanos,
// total de empleados y total de actividades.
// Si hay conexión real, consulta la base de datos
// Si no, calcula los mismos números a partir de los datos DEMO.

app.get('/api/stats', (req, res) => {
    if (conexion.state === 'authenticated') {
        // Sentencias SQL para cada estadística
        const sqlAnimales    = 'SELECT COUNT(*) AS total FROM animal';
        const sqlSanos       = "SELECT COUNT(*) AS total FROM animal WHERE estado_salud = 'buena'";
        const sqlEmpleados   = 'SELECT COUNT(*) AS total FROM empleado';
        const sqlActividades = 'SELECT COUNT(*) AS total FROM actividad';

        // Lanzamos las 4 consultas en paralelo y esperamos que todas terminen
        Promise.all([
            new Promise((resolve) => hacerConsulta(sqlAnimales, [], resolve)),
            new Promise((resolve) => hacerConsulta(sqlSanos, [], resolve)),
            new Promise((resolve) => hacerConsulta(sqlEmpleados, [], resolve)),
            new Promise((resolve) => hacerConsulta(sqlActividades, [], resolve))
        ]).then(([ani, san, emp, act]) => {
            res.json({
                data: {
                    animales:    ani ? ani[0].total : DEMO.animales.length,
                    sanos:       san ? san[0].total : DEMO.animales.filter(a => a.estado_salud === 'buena').length,
                    empleados:   emp ? emp[0].total : DEMO.empleados.length,
                    actividades: act ? act[0].total : DEMO.actividades.length
                },
                demo: !ani
            });
        });
    } else {
        // Sin conexión, calculamos los datos desde DEMO
        const totalSanos = DEMO.animales.filter(a => a.estado_salud === 'buena').length;
        res.json({
            data: {
                animales:    DEMO.animales.length,
                sanos:       totalSanos,
                empleados:   DEMO.empleados.length,
                actividades: DEMO.actividades.length
            },
            demo: true
        });
    }
});

// MANEJO DE RUTAS NO ENCONTRADAS (ERROR 404)
// Si la petición empieza por '/api' y no coincide con ninguna ruta anterior,
// devolvemos un JSON informando del error y listando las rutas disponibles.


app.use((req, res) => {
    if (req.path.startsWith('/api')) {
        return res.status(404).json({
            error: 'Ruta no encontrada',
            rutasDisponibles: [
                'GET  /api/animales',
                'GET  /api/empleados',
                'GET  /api/actividades',
                'GET  /api/stats',
                'POST /api/consulta',
            ]
        });
    }
    res.status(404).sendFile(path.join(__dirname, 'public', '404.html'));
});

// INICIAR EL SERVIDOR 
// Ponemos a Express a escuchar en el puerto 3000 y mostramos en consola.
app.listen(PORT, () => {
    console.log('Servidor Express arrancado correctamente');
    console.log(`Abre tu navegador en: http://localhost:${PORT}`);
    console.log('Rutas disponibles:');
    console.log(`  GET  http://localhost:${PORT}/api/animales`);
    console.log(`  GET  http://localhost:${PORT}/api/empleados`);
    console.log(`  GET  http://localhost:${PORT}/api/actividades`);
    console.log(`  GET  http://localhost:${PORT}/api/stats`);
    console.log(`  POST http://localhost:${PORT}/api/consulta`);
});