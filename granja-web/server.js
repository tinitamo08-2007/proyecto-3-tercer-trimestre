// IMPORTACIONES
const express = require('express');
const mysql   = require('mysql2');
const path    = require('path');

// CONFIGURACIÓN INICIAL
const app  = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// CONEXIÓN A MYSQL
const conexion = mysql.createConnection({
    host:     'granja-mysql-granjamysql.j.aivencloud.com',
    user:     'avnadmin',
    port:     '18071',
    password: '(Mete aquí la contraseña)',
    database: 'granja',
});

conexion.connect((err) => {
    if (err) {
        console.log('Sin conexión a MySQL, usando datos de demo.');
    } else {
        console.log('Conectado a MySQL correctamente.');
    }
});

// DATOS DE DEMO
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
        { id:1, nombre:'Maria Lopez',     rol:'veterinario', telefono:'666111222' },
        { id:2, nombre:'Juan Perez',      rol:'peon',        telefono:'655234567' },
        { id:3, nombre:'Lucia Fernandez', rol:'encargado',   telefono:'644555888' },
        { id:4, nombre:'Carlos Romero',   rol:'peon',        telefono:'633998877' },
        { id:5, nombre:'Sofia Ruiz',      rol:'veterinario', telefono:'611222333' },
    ],
    actividades: [
        { id:1, fecha:'2026-05-10', hora:'06:30', tipo:'ORDENIE',      empleado:'Juan Perez',    animales:'ARETE-001, ARETE-002' },
        { id:2, fecha:'2026-05-10', hora:'08:00', tipo:'ALIMENTACION', empleado:'Juan Perez',    animales:'ARETE-001, ARETE-002, ARETE-003' },
        { id:3, fecha:'2026-05-10', hora:'10:15', tipo:'VACUNACION',   empleado:'Maria Lopez',   animales:'ARETE-102' },
        { id:4, fecha:'2026-05-10', hora:'17:30', tipo:'LIMPIEZA',     empleado:'Carlos Romero', animales:'ANILLA-301' },
        { id:5, fecha:'2026-05-11', hora:'06:30', tipo:'ORDENIE',      empleado:'Juan Perez',    animales:'ARETE-001, ARETE-002' },
    ],
};

// FUNCIÓN PARA HACER CONSULTAS
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

// APIs GET
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
    hacerConsulta('SELECT * FROM vista_actividades', [], (datos) => {
        res.json({
            data: datos || DEMO.actividades,
            demo: !datos
        });
    });
});

// API POST
app.post('/api/consulta', (req, res) => {
    const tipo   = req.body.tipo;
    const filtro = req.body.filtro;

    if (!tipo) {
        return res.status(400).json({
            error: 'Falta el campo tipo',
            ejemplo: '{ "tipo": "animales_especie", "filtro": "Bovino" }'
        });
    }

    const consultas = {
        animales_especie:  "SELECT * FROM animal          WHERE especie      LIKE CONCAT('%', ?, '%')",
        empleados_rol:     "SELECT * FROM empleado         WHERE rol          LIKE CONCAT('%', ?, '%')",
        actividades_fecha: "SELECT * FROM vista_actividades WHERE fecha        LIKE CONCAT('%', ?, '%')",
        animales_salud:    "SELECT * FROM animal          WHERE estado_salud LIKE CONCAT('%', ?, '%')",
    };

    if (!consultas[tipo]) {
        return res.status(400).json({
            error: 'Tipo de consulta no válido',
            tiposPermitidos: Object.keys(consultas)
        });
    }

    hacerConsulta(consultas[tipo], [filtro || ''], (datos) => {
        res.json({
            data:     datos || DEMO[tipo.split('_')[0]],
            demo:     !datos,
            total:    datos ? datos.length : 0,
            consulta: tipo.replace('_', ' por ')
        });
    });
});

// ─── NUEVA RUTA: GET /api/stats ───
app.get('/api/stats', (req, res) => {
    // Si hay conexión a la BD, hacemos consultas reales
    if (conexion.state === 'authenticated') {
        const sqlAnimales     = 'SELECT COUNT(*) AS total FROM animal';
        const sqlSanos        = "SELECT COUNT(*) AS total FROM animales WHERE estado_salud = 'Sano'";
        const sqlEmpleados    = 'SELECT COUNT(*) AS total FROM empleadO';
        const sqlActividades  = 'SELECT COUNT(*) AS total FROM actividad';

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
        // Sin BD: datos de demostración
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

// ERROR 404
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

// INICIAR SERVIDOR
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
