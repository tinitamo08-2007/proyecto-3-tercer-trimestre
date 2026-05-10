const SECCIONES = {
  inicio: 'sec-inicio',
  informacion: 'sec-informacion',
  consultas: 'sec-consultas'
};

// Seleccionamos todos los botones del menú 
const BOTONES_NAV = document.querySelectorAll('nav button');
//  FUNCIÓN PARA CAMBIAR DE SECCIÓN

function navigate(seccion) {
  //  Ocultamos todas las secciones
  Object.values(SECCIONES).forEach(id => {
    document.getElementById(id).classList.remove('active');
  });

  //  Mostramos la sección que hemos elegido
  document.getElementById(SECCIONES[seccion]).classList.add('active');

  //  Marcamos el botón activo en el menú
  // Recorremos los botones y comparamos su posición 
  BOTONES_NAV.forEach((boton, indice) => {
    const secciones = ['inicio', 'informacion', 'consultas'];
    // Si coincide, añadimos la clase 'active', si no, la quitamos
    boton.classList.toggle('active', secciones[indice] === seccion);
  });

  //  El bloque hero  solo se muestra en la vista "Inicio"
  const hero = document.getElementById('hero-block');
  if (seccion === 'inicio') {
    hero.style.display = '';         // se muestra 
  } else {
    hero.style.display = 'none';    // se oculta
  }

  //  Si vamos a "Información", reseteamos la pestaña para recargargarla
  if (seccion === 'informacion') {
    pestañaActual = '';   // fuerza recarga aunque ya estuviera activa
    cargarPestaña('animales');
  }
}

//  ESTADÍSTICAS 
async function cargarEstadisticas() {
  try {
    // Hacemos una petición a la API del servidor que nos devuelve los totales
    const respuesta = await fetch('/api/stats');
    if (!respuesta.ok) throw new Error('El servidor no respondió bien');

    // Convertimos la respuesta en un objeto JavaScript
    const resultado = await respuesta.json();

    // Ponemos los números en cada tarjeta
    document.getElementById('stat-animales').innerHTML = resultado.data.animales + (resultado.demo ? '<span class="demo-badge">DEMO</span>' : '');
    document.getElementById('stat-sanos').innerHTML = resultado.data.sanos;
    document.getElementById('stat-empleados').innerHTML = resultado.data.empleados;
    document.getElementById('stat-actividades').innerHTML = resultado.data.actividades;
  } catch (error) {
    // Si hay un error (por ejemplo no hay conexión), mostramos "Error" en todas las tarjetas
    console.error('Error al cargar estadísticas:', error);
    ['stat-animales', 'stat-sanos', 'stat-empleados', 'stat-actividades'].forEach(id => {
      document.getElementById(id).innerHTML = 'Error';
    });
  }
}

//  PESTAÑAS DE INFORMACIÓN 
let pestañaActual = '';  // recordamos la última pestaña cargada para no repetir

async function cargarPestaña(tipo) {  // tipo puede ser 'animales', 'empleados', 'actividades'
  // Si ya estamos mostrando esa pestaña, no hacemos nada
  if (pestañaActual === tipo) return;
  pestañaActual = tipo;

  // Activamos visualmente el botón correcto 
  const botonesPestaña = document.querySelectorAll('.btn-tab');
  botonesPestaña.forEach((boton, indice) => {
    const pestañas = ['animales', 'empleados', 'actividades'];
    boton.classList.toggle('active', pestañas[indice] === tipo);
  });

  // Mostramos un mensaje de "cargando..."
  const contenedor = document.getElementById('table-container');
  contenedor.innerHTML = '<div class="loader"><div class="spinner-border text-success mb-3"></div><br/>Cargando ' + tipo + '...</div>';

  try {
    // Pedimos los datos al servidor
    const respuesta = await fetch('/api/' + tipo);
    const resultado = await respuesta.json();
    // Generamos la tabla con los datos recibidos
    contenedor.innerHTML = generarTabla(tipo, resultado.data, resultado.demo);
  } catch (error) {
    contenedor.innerHTML = '<div class="loader"> Error al cargar los datos.</div>';
  }
}

//  CONSTRUIR UNA TABLA A PARTIR DE LOS DATOS
function generarTabla(tipo, datos, esDemo) {
  // Si el array viene vacío, mostramos un mensaje
  if (!datos || datos.length === 0) {
    return '<div class="loader">No hay datos disponibles.</div>';
  }
  // Si es modo demostración, mostramos un aviso
  let avisoDemo = '';
  if (esDemo) {
    avisoDemo = '<p style="color:var(--rust); font-size:0.8rem; margin-bottom:0.75rem;">⚠ Datos de demostración (base de datos no conectada)</p>';
  }

  let columnas = [];
  let filasHTML = '';

  // Dependiendo del tipo, creamos las cabeceras y las filas
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
        <td>${act.tipo_actividad}</td>
        <td>${act.empleado}</td>
        <td><small>${act.animales}</small></td>
      </tr>`).join('');
  }

  // Devolvemos el HTML completo de la tabla
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


//  BADGE DE COLOR SEGÚN EL ESTADO DE SALUD

function crearBadgeSalud(estado) {
  if (!estado) return '—'; // por si viene vacío

  const texto = estado.toLowerCase();

  if (texto.includes('sano')) {
    return `<span class="badge-salud verde">${estado}</span>`;
  } else if (texto.includes('tratamiento')) {
    return `<span class="badge-salud ambar">${estado}</span>`;
  } else {
    // Cualquier otro estado (ej. enfermo) lo mostramos en rojo
    return `<span class="badge-salud rojo">${estado}</span>`;
  }
}
//  FORMULARIO DE CONSULTAS

// Cambia el texto de ejemplo cuando se elige un tipo de consulta
function actualizarPlaceholder() {
  const tipo = document.getElementById('q-tipo').value;
  const inputFiltro = document.getElementById('q-filtro');

  const ejemplos = {
    animales_especie:  'Ej: Bovino, Porcino, Ovino...',
    empleados_rol:     'Ej: Veterinario, Peón, Encargado...',
    actividades_fecha: 'Ej: 2024-05-01',
    animales_salud:    'Ej: Sano, En tratamiento...',
  };

  inputFiltro.placeholder = ejemplos[tipo] || 'Escribe un filtro...';

  // Si es consulta por fecha, mostramos un selector de fecha; si no, un campo de texto
  if (tipo === 'actividades_fecha') {
    inputFiltro.type = 'date';
  } else {
    inputFiltro.type = 'text';
  }

  // Limpiamos los mensajes de error anteriores
  limpiarErrores();
}

function limpiarErrores() {
  // Quitamos la clase de campo inválido de Bootstrap
  document.getElementById('q-tipo').classList.remove('is-invalid');
  document.getElementById('q-filtro').classList.remove('is-invalid');
  // Ocultamos los mensajes de error
  document.getElementById('err-tipo').style.display = 'none';
  document.getElementById('err-filtro').style.display = 'none';
}

// Comprueba que el formulario esté bien antes de enviar
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

  // El filtro no puede tener caracteres peligrosos 
  if (filtro && /['";<>\\]/.test(filtro)) {
    document.getElementById('q-filtro').classList.add('is-invalid');
    document.getElementById('err-filtro').style.display = 'block';
    esValido = false;
  }

  return esValido;
}

// Envía la consulta al servidor y muestra los resultados
async function ejecutarConsulta() {
  if (!validarFormulario()) return;  // si no es válido, paramos aquí

  const tipo   = document.getElementById('q-tipo').value;
  const filtro = document.getElementById('q-filtro').value.trim();
  const boton  = document.getElementById('btn-consultar');
  const zonaResultados = document.getElementById('query-results');

  // Desactivamos el botón mientras se busca y ponemos texto de "Buscando..."
  boton.disabled = true;
  boton.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Buscando...';

  // Ocultamos resultados anteriores
  zonaResultados.style.display = 'none';

  try {
    const respuesta = await fetch('/api/consulta', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tipo: tipo, filtro: filtro })
    });

    const resultado = await respuesta.json();

    if (!respuesta.ok) {
      // Si el servidor devuelve un error, mostramos el mensaje
      zonaResultados.innerHTML = `<div class="loader"> ${resultado.error}</div>`;
    } else {
      // Averiguamos de qué tabla vienen los datos (animales, empleados o actividades)
      const tabla = tipo.split('_')[0];
      let avisoDemo = '';
      if (resultado.demo) {
        avisoDemo = '<p style="color:var(--rust); font-size:0.8rem; margin-bottom:0.75rem;">⚠ Datos de demostración</p>';
      }

      // Construimos el HTML del encabezado de resultados + la tabla
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
    // Error de conexión (no se pudo llegar al servidor)
    zonaResultados.innerHTML = '<div class="loader"> Error de conexión con el servidor.</div>';
    zonaResultados.style.display = 'block';
  } finally {
    // Activamos de nuevo el botón, tanto si fue bien como si hubo error
    boton.disabled = false;
    boton.innerHTML = '<i class="bi bi-search me-1"></i> Buscar';
  }
}

cargarEstadisticas();