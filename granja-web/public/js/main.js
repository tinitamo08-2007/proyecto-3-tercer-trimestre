// Objeto que mapea nombres de secciones con los IDs de los elementos HTML
const SECCIONES = {
  inicio: 'sec-inicio',
  informacion: 'sec-informacion',
  consultas: 'sec-consultas'
};

// Guardamos todos los botones del menú de navegación para usarlos después
const BOTONES_NAV = document.querySelectorAll('nav button');

/**
 * Cambia la sección visible en la interfaz.
 * Oculta todas, muestra la elegida, actualiza el botón activo del menú,
 * controla la visibilidad del bloque hero y reinicia la pestaña de Información si es necesario.
 */
function navigate(seccion) {
  // Quitamos la clase 'active' de todas las secciones
  Object.values(SECCIONES).forEach(id => {
    document.getElementById(id).classList.remove('active');
  });

  // Activamos la sección solicitada
  document.getElementById(SECCIONES[seccion]).classList.add('active');

  // Actualizamos el estilo del botón activo comparando su posición con el nombre de sección
  BOTONES_NAV.forEach((boton, indice) => {
    const secciones = ['inicio', 'informacion', 'consultas'];
    boton.classList.toggle('active', secciones[indice] === seccion);
  });

  // El bloque principal (hero) solo se ve en la vista de inicio
  const hero = document.getElementById('hero-block');
  if (seccion === 'inicio') {
    hero.style.display = '';        // lo mostramos
  } else {
    hero.style.display = 'none';    // lo escondemos
  }

  // Al entrar a Información forzamos la recarga de la pestaña inicial
  if (seccion === 'informacion') {
    pestañaActual = '';            // resetea la memoria de pestaña
    cargarPestaña('animales');
  }
}

/*
 * Obtiene del servidor los totales para las tarjetas de estadísticas.
 * Si la respuesta es de datos demo, añade una etiqueta indicándolo.
 * En caso de error muestra "Error" en cada tarjeta.
 */
async function cargarEstadisticas() {
  try {
    const respuesta = await fetch('/api/stats');
    
    if (!respuesta.ok) throw new Error('El servidor no respondió bien');
    const resultado = await respuesta.json();

    // Insertamos los números en el HTML de las tarjetas
    document.getElementById('stat-animales').innerHTML = resultado.data.animales +
    (resultado.demo ? '<span class="demo-badge">DEMO</span>' : '');
    document.getElementById('stat-sanos').innerHTML = resultado.data.sanos;
    document.getElementById('stat-empleados').innerHTML = resultado.data.empleados;
    document.getElementById('stat-actividades').innerHTML = resultado.data.actividades;
  } catch (error) {
    console.error('Error al cargar estadísticas:', error);
    // Si falla, ponemos "Error" en todas las tarjetas
    ['stat-animales', 'stat-sanos', 'stat-empleados', 'stat-actividades'].forEach(id => {
      document.getElementById(id).innerHTML = 'Error';
    });
  }
}

// Variable que recuerda la pestaña actual para evitar recargas innecesarias
let pestañaActual = '';

/**
 * Carga y muestra una de las pestañas de información.
 * Si ya está cargada, no hace nada. Si no, resalta el botón, muestra un spinner
 * y pide los datos al servidor para generar la tabla.
 */
async function cargarPestaña(tipo) {
  if (pestañaActual === tipo) return;   // ya está visible
  pestañaActual = tipo;

  // Activamos el botón de la pestaña correspondiente
  const botonesPestaña = document.querySelectorAll('.btn-tab');
  botonesPestaña.forEach((boton, indice) => {
    const pestañas = ['animales', 'empleados', 'actividades'];
    boton.classList.toggle('active', pestañas[indice] === tipo);
  });

  // Indicador de carga
  const contenedor = document.getElementById('table-container');
  contenedor.innerHTML = `<div class="loader"><div class="spinner-border text-success mb-3"></div><br/>Cargando ${tipo}...</div>`;

  try {
    const respuesta = await fetch('/api/' + tipo);
    const resultado = await respuesta.json();
    // Generamos la tabla con los datos recibidos y la metemos en el contenedor
    contenedor.innerHTML = generarTabla(tipo, resultado.data, resultado.demo);
  } catch (error) {
    contenedor.innerHTML = '<div class="loader"> Error al cargar los datos.</div>';
  }
}

/**
 * Construye una tabla HTML a partir del tipo de datos, el array de registros y el demo.
 * Devuelve una cadena de texto con la tabla o un mensaje si no hay datos.
 */
function generarTabla(tipo, datos, esDemo) {
  if (!datos || datos.length === 0) {
    return '<div class="loader">No hay datos disponibles.</div>';
  }

  // Aviso si los datos son de demostración
  let avisoDemo = '';
  if (esDemo) {
    avisoDemo = '<p style="color:var(--rust); font-size:0.8rem; margin-bottom:0.75rem;">⚠ Datos de demostración (base de datos no conectada)</p>';
  }

  let columnas = [];
  let filasHTML = '';

  // Definimos columnas y generamos las filas según el tipo de contenido
  if (tipo === 'animales') {
    columnas = ['ID', 'Especie', 'Raza', 'Nacimiento', 'Identificador', 'Salud', 'Ubicación'];
    filasHTML = datos.map(animal => `
      <tr>
        <td><code>${animal.id}</code></td>
        <td>${animal.especie}</td>
        <td>${animal.raza}</td>
        <td>${animal.fecha_nacimiento || '—'}</td>
        <td><code>${animal.identificador}</code></td>
        <td>${crearBadgeSalud(animal.estado_salud)}</td>
        <td>${animal.ubicacion}</td>
      </tr>`).join('');
  } else if (tipo === 'empleados') {
    columnas = ['ID', 'Nombre', 'Rol', 'Teléfono', 'Contratación'];
    filasHTML = datos.map(emp => `
      <tr>
        <td><code>${emp.id}</code></td>
        <td><strong>${emp.nombre}</strong></td>
        <td>${emp.rol}</td>
        <td>${emp.telefono}</td>
        <td>${emp.fecha_contratacion}</td>
      </tr>`).join('');
  } else if (tipo === 'actividades') {
    columnas = ['ID', 'Fecha', 'Hora', 'Actividad', 'Responsable', 'Animales'];
    filasHTML = datos.map(act => `
      <tr>
        <td><code>${act.id}</code></td>
        <td>${act.fecha}</td>
        <td>${act.hora}</td>
        <td>${act.tipo}</td>
        <td>${act.empleado}</td>
        <td><small>${act.animales}</small></td>
      </tr>`).join('');
  }

  // Devolvemos el HTML completo con el aviso y la tabla
  return avisoDemo + `
    <div class="table-wrap">
      <table class="table table-striped table-hover">
        <thead>
          <tr>${columnas.map(col => `<th>${col}</th>`).join('')}</tr>
        </thead>
        <tbody>
          ${filasHTML}
        </tbody>
      </table>
    </div>`;
}

/**
 * Genera una etiqueta coloreada según el estado de salud del animal.
 * Verde para "buena", amarillo para "regular", rojo para cualquier otro.
 */
function crearBadgeSalud(estado) {
  if (!estado) return '—';

  const texto = estado.toLowerCase();
  if (texto === 'buena') {
    return `<span class="badge-salud verde">${estado}</span>`;
  } else if (texto === 'regular') {
    return `<span class="badge-salud amarillo">${estado}</span>`;
  } else {
    return `<span class="badge-salud rojo">${estado}</span>`;
  }
}

// LÓGICA DEL FORMULARIO DE CONSULTAS
/**
 * Ajusta el placeholder y el tipo de input según la opción de consulta seleccionada.
 * También limpia mensajes de error previos.
 */
function actualizarPlaceholder() {
  const tipo = document.getElementById('q-tipo').value;
  const inputFiltro = document.getElementById('q-filtro');

  // Placeholders de ejemplo para cada tipo de búsqueda
  const ejemplos = {
    animales_especie:  'Ej: Bovino, Porcino, Ovino...',
    empleados_rol:     'Ej: Veterinario, Peón, Encargado...',
    actividades_fecha: 'Ej: 2024-05-01',
    animales_salud:    'Ej: buena, regular, grave, critica',
  };

  inputFiltro.placeholder = ejemplos[tipo] || 'Escribe un filtro...';

  // Para fechas usamos un input de tipo date; para el resto, texto normal
  inputFiltro.type = (tipo === 'actividades_fecha') ? 'date' : 'text';

  limpiarErrores();
}

/** Quita las marcas de error del formulario */
function limpiarErrores() {
  document.getElementById('q-tipo').classList.remove('is-invalid');
  document.getElementById('q-filtro').classList.remove('is-invalid');
  document.getElementById('err-tipo').style.display = 'none';
  document.getElementById('err-filtro').style.display = 'none';
}

/**
 * Valida que se haya seleccionado un tipo de consulta y que el filtro no contenga
 * caracteres potencialmente peligrosos. Retorna true si es válido.
 */
function validarFormulario() {
  limpiarErrores();
  let esValido = true;

  const tipo = document.getElementById('q-tipo').value;
  const filtro = document.getElementById('q-filtro').value;

  // El tipo es obligatorio
  if (!tipo) {
    document.getElementById('q-tipo').classList.add('is-invalid');
    document.getElementById('err-tipo').style.display = 'block';
    esValido = false;
  }

  // Bloqueamos caracteres como comillas, barras, etc. que no deberían ir en una búsqueda
  if (filtro && /['";<>\\]/.test(filtro)) {
    document.getElementById('q-filtro').classList.add('is-invalid');
    document.getElementById('err-filtro').style.display = 'block';
    esValido = false;
  }

  return esValido;
}

/**
 * Envía la consulta al servidor y muestra los resultados en la zona correspondiente.
 * Maneja los estados de carga, desactiva el botón mientras se procesa,
 * y distingue entre respuestas de error y datos válidos.
 */
async function ejecutarConsulta() {
  if (!validarFormulario()) return;

  const tipo   = document.getElementById('q-tipo').value;
  const filtro = document.getElementById('q-filtro').value.trim();
  const boton  = document.getElementById('btn-consultar');
  const zonaResultados = document.getElementById('query-results');

  //  botón deshabilitado con spinner
  boton.disabled = true;
  boton.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Buscando...';
  zonaResultados.style.display = 'none';

  try {
    const respuesta = await fetch('/api/consulta', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tipo, filtro })
    });

    const resultado = await respuesta.json();

    if (!respuesta.ok) {
      // Muestra el mensaje de error que devuelve la API
      zonaResultados.innerHTML = `<div class="loader"> ${resultado.error}</div>`;
    } else {
      // Determina el tipo de tabla (animales, empleados, actividades) a partir del tipo de consulta
      const tabla = tipo.split('_')[0];
      let avisoDemo = resultado.demo
        ? '<p style="color:var(--rust); font-size:0.8rem; margin-bottom:0.75rem;">Datos de demostración</p>'
        : '';

      // Construye el bloque de resultados: cabecera + tabla generada
      zonaResultados.innerHTML = `
        ${avisoDemo}
        <div class="results-header">
          <div class="results-titulo">Resultados: ${resultado.consulta}</div>
          <div class="results-count">${resultado.total} registros</div>
        </div>
        ${generarTabla(tabla, resultado.data, resultado.demo)}
      `;
    }
    zonaResultados.style.display = 'block';
  } catch (error) {
    // Error de red o del servidor
    zonaResultados.innerHTML = '<div class="loader"> Error de conexión con el servidor.</div>';
    zonaResultados.style.display = 'block';
  } finally {
    // Reactivamos el botón pase lo que pase
    boton.disabled = false;
    boton.innerHTML = '<i class="bi bi-search me-1"></i> Buscar';
  }
}

// Al cargar la página, mostramos inmediatamente las estadísticas
cargarEstadisticas();