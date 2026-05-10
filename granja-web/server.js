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
    host:     'localhost',
    user:     'root',
    password: 'proyecto-3-tercer-trimestre',
    database: 'GranjaMySQL',
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
        { id: 1, especie: 'Bovino',  raza: 'Holstein', fecha_nacimiento: '2020-03-15', identificador: 'A-001', estado_salud: 'Sano',           ubicacion: 'Corral 1'  },
        { id: 2, especie: 'Porcino', raza: 'Duroc',    fecha_nacimiento: '2021-07-22', identificador: 'A-002', estado_salud: 'Sano',           ubicacion: 'Potrero 2' },
        { id: 3, especie: 'Ovino',   raza: 'Merino',   fecha_nacimiento: '2019-11-08', identificador: 'A-003', estado_salud: 'En tratamiento', ubicacion: 'Corral 3'  },
    ],
    empleados: [
        { id: 1, nombre: 'Carlos Martínez', rol: 'Veterinario', telefono: '612345678', fecha_contratacion: '2022-01-10' },
        { id: 2, nombre: 'Ana López',       rol: 'Encargada',   telefono: '623456789', fecha_contratacion: '2021-06-01' },
        { id: 3, nombre: 'Pedro Sánchez',   rol: 'Peón',        telefono: '634567890', fecha_contratacion: '2023-03-15' },
    ],
    actividades: [
        { id: 1, fecha: '2024-05-01', hora: '08:00', tipo_actividad: 'Ordeño',       empleado: 'Ana López',       animales: 'A-001, A-002' },
        { id: 2, fecha: '2024-05-01', hora: '09:30', tipo_actividad: 'Vacunación',   empleado: 'Carlos Martínez', animales: 'A-003'        },
        { id: 3, fecha: '2024-05-02', hora: '07:00', tipo_actividad: 'Alimentación', empleado: 'Pedro Sánchez',   animales: 'A-001, A-002, A-003' },
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
    hacerConsulta('SELECT * FROM animales', [], (datos) => {
        res.json({
            data: datos || DEMO.animales,
            demo: !datos
        });
    });
});

app.get('/api/empleados', (req, res) => {
    hacerConsulta('SELECT * FROM empleados', [], (datos) => {
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
        animales_especie:  'SELECT * FROM animales WHERE especie = ?',
        empleados_rol:     'SELECT * FROM empleados WHERE rol = ?',
        actividades_fecha: 'SELECT * FROM vista_actividades WHERE fecha = ?',
        animales_salud:    'SELECT * FROM animales WHERE estado_salud = ?',
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
        const sqlAnimales     = 'SELECT COUNT(*) AS total FROM animales';
        const sqlSanos        = "SELECT COUNT(*) AS total FROM animales WHERE estado_salud = 'Sano'";
        const sqlEmpleados    = 'SELECT COUNT(*) AS total FROM empleados';
        const sqlActividades  = 'SELECT COUNT(*) AS total FROM actividades';

        Promise.all([
            new Promise((resolve) => hacerConsulta(sqlAnimales, [], resolve)),
            new Promise((resolve) => hacerConsulta(sqlSanos, [], resolve)),
            new Promise((resolve) => hacerConsulta(sqlEmpleados, [], resolve)),
            new Promise((resolve) => hacerConsulta(sqlActividades, [], resolve))
        ]).then(([ani, san, emp, act]) => {
            res.json({
                data: {
                    animales:    ani ? ani[0].total : DEMO.animales.length,
                    sanos:       san ? san[0].total : DEMO.animales.filter(a => a.estado_salud === 'Sano').length,
                    empleados:   emp ? emp[0].total : DEMO.empleados.length,
                    actividades: act ? act[0].total : DEMO.actividades.length
                },
                demo: !ani
            });
        });
    } else {
        // Sin BD: datos de demostración
        const totalSanos = DEMO.animales.filter(a => a.estado_salud === 'Sano').length;
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