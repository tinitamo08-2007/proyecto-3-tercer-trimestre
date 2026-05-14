package granja.controlador;

import granja.dao.ActividadDAO;
import granja.dao.AnimalDAO;
import granja.dao.ConexionBD;
import granja.dao.EmpleadoDAO;
import granja.excepciones.DatoInvalidoException;
import granja.modelo.Actividad;
import granja.modelo.Animal;
import granja.modelo.Empleado;
import granja.modelo.EstadoAnimal;
import granja.modelo.TipoActividad;
import granja.util.CopiaSeguridadUtil;
import granja.util.ExportadorExcel;
import granja.util.ExportadorPDF;
import granja.util.RegistroLog;
import granja.util.ValidadorDatos;
import granja.vista.VistaConsola;

import java.nio.file.Path;
import java.sql.SQLException;
import java.util.List;

/**
 * Orquesta toda la aplicación.
 *
 * Pasos típicos:
 *   1. Prueba la conexión con la BD al arrancar.
 *   2. Muestra el menú principal en bucle.
 *   3. Para cada opción llama al DAO correspondiente y captura sus errores.
 *
 * Toda la entrada/salida se hace a través de la VistaConsola.
 * Toda la persistencia se hace a través de los DAO.
 */
public class ControladorGranja {

    private final VistaConsola vista = new VistaConsola();
    private final AnimalDAO animalDAO = new AnimalDAO();
    private final EmpleadoDAO empleadoDAO = new EmpleadoDAO();
    private final ActividadDAO actividadDAO = new ActividadDAO();

    /**
     * Punto de entrada del controlador. Llamar desde Principal.main().
     */
    public void iniciar() {
        RegistroLog.registrar("Aplicación iniciada.");

        if (!ConexionBD.probarConexion()) {
            vista.mostrarError("No se ha podido conectar con la base de datos.");
            vista.mostrarMensaje(
                    "Revisa config.properties (URL, usuario y contraseña) y que MySQL esté en marcha.\n"
                    + "También que exista la BD 'granja_digital' (ver script de la carpeta GranjaMySQL).");
            RegistroLog.error("Conexión con la BD fallida al iniciar.");
            return;
        }
        vista.mostrarMensaje("Conexión con la BD correcta. ¡Bienvenido!");

        boolean seguir = true;
        while (seguir) {
            vista.mostrarMenuPrincipal();
            int op = vista.pedirEntero("Elige una opción");
            try {
                switch (op) {
                    case 1: menuAnimales(); break;
                    case 2: menuEmpleados(); break;
                    case 3: menuActividades(); break;
                    case 4: menuReportes(); break;
                    case 5: hacerCopiaSeguridad(); break;
                    case 6: exportarExcel(); break;
                    case 7: exportarPDF(); break;
                    case 0: seguir = false; break;
                    default: vista.mostrarMensaje("Opción no válida.");
                }
            } catch (DatoInvalidoException e) {
                vista.mostrarError(e.getMessage());
                RegistroLog.advertencia("Dato inválido: " + e.getMessage());
            } catch (SQLException e) {
                vista.mostrarError("Error de base de datos: " + e.getMessage());
                RegistroLog.error("SQLException: " + e.getMessage());
            } catch (Exception e) {
                vista.mostrarError("Error inesperado: " + e.getMessage());
                RegistroLog.error("Excepción inesperada: " + e);
            }
        }

        vista.mostrarMensaje("Hasta luego.");
        RegistroLog.registrar("Aplicación cerrada por el usuario.");
    }

    // =====================================================
    //  ANIMALES
    // =====================================================

    private void menuAnimales() throws SQLException {
        boolean volver = false;
        while (!volver) {
            vista.mostrarMenuAnimales();
            int op = vista.pedirEntero("Elige una opción");
            switch (op) {
                case 1: registrarAnimal(); break;
                case 2: listarAnimales(); break;
                case 3: buscarAnimal(); break;
                case 4: editarAnimal(); break;
                case 5: cambiarEstadoAnimal(); break;
                case 6: eliminarAnimal(); break;
                case 0: volver = true; break;
                default: vista.mostrarMensaje("Opción no válida.");
            }
        }
    }

    private void registrarAnimal() throws SQLException {
        vista.mostrarTitulo("Nuevo animal");
        Animal a = new Animal();
        a.setEspecie(ValidadorDatos.exigirTexto(vista.pedirTexto("Especie"), "Especie"));
        a.setRaza(ValidadorDatos.exigirTexto(vista.pedirTexto("Raza"), "Raza"));
        a.setFechaNacimiento(ValidadorDatos.exigirFecha(
                vista.pedirTexto("Fecha de nacimiento (yyyy-MM-dd)"), "Fecha nacimiento"));
        a.setIdentificador(ValidadorDatos.exigirTexto(
                vista.pedirTexto("Identificador (arete/chip)"), "Identificador"));
        a.setEstadoSalud(ValidadorDatos.exigirTexto(
                vista.pedirTexto("Estado de salud"), "Estado de salud"));
        a.setUbicacion(ValidadorDatos.exigirTexto(
                vista.pedirTexto("Ubicación"), "Ubicación"));
        a.setEstado(EstadoAnimal.ACTIVO);

        int id = animalDAO.insertar(a);
        vista.mostrarMensaje("Animal registrado con ID " + id);
        RegistroLog.registrar("Animal registrado id=" + id + " (" + a.getEspecie() + ")");
    }

    private void listarAnimales() throws SQLException {
        vista.mostrarTitulo("Listado de animales");
        List<Animal> lista = animalDAO.listar();
        if (lista.isEmpty()) {
            vista.mostrarMensaje("No hay animales registrados.");
            return;
        }
        for (Animal a : lista) {
            vista.mostrarMensaje(a.toString());
        }
    }

    private void buscarAnimal() throws SQLException {
        int id = vista.pedirEntero("ID del animal");
        Animal a = animalDAO.buscarPorId(id);
        if (a == null) {
            vista.mostrarMensaje("No existe un animal con id=" + id);
        } else {
            vista.mostrarMensaje(a.toString());
        }
    }

    private void editarAnimal() throws SQLException {
        int id = vista.pedirEntero("ID del animal a editar");
        Animal a = animalDAO.buscarPorId(id);
        if (a == null) {
            vista.mostrarMensaje("No existe un animal con id=" + id);
            return;
        }
        vista.mostrarMensaje("Pulsa Intro para conservar el valor actual.");
        a.setEspecie(noVacio(vista.pedirTexto("Especie [" + a.getEspecie() + "]"), a.getEspecie()));
        a.setRaza(noVacio(vista.pedirTexto("Raza [" + a.getRaza() + "]"), a.getRaza()));
        a.setFechaNacimiento(noVacio(
                vista.pedirTexto("Fecha nac. [" + a.getFechaNacimiento() + "]"), a.getFechaNacimiento()));
        a.setIdentificador(noVacio(
                vista.pedirTexto("Identificador [" + a.getIdentificador() + "]"), a.getIdentificador()));
        a.setEstadoSalud(noVacio(
                vista.pedirTexto("Salud [" + a.getEstadoSalud() + "]"), a.getEstadoSalud()));
        a.setUbicacion(noVacio(
                vista.pedirTexto("Ubicación [" + a.getUbicacion() + "]"), a.getUbicacion()));

        boolean ok = animalDAO.actualizar(a);
        vista.mostrarMensaje(ok ? "Animal actualizado." : "No se ha modificado nada.");
        RegistroLog.registrar("Animal editado id=" + id);
    }

    private void cambiarEstadoAnimal() throws SQLException {
        int id = vista.pedirEntero("ID del animal");
        Animal a = animalDAO.buscarPorId(id);
        if (a == null) {
            vista.mostrarMensaje("No existe un animal con id=" + id);
            return;
        }
        EstadoAnimal nuevo = vista.pedirEstadoAnimal();
        a.setEstado(nuevo);
        animalDAO.actualizar(a);
        vista.mostrarMensaje("Estado del animal cambiado a " + nuevo);
        RegistroLog.registrar("Animal id=" + id + " -> estado " + nuevo);
    }

    private void eliminarAnimal() throws SQLException {
        int id = vista.pedirEntero("ID del animal a eliminar");
        if (!vista.pedirConfirmacion("¿Confirmas el borrado?")) {
            return;
        }
        boolean ok = animalDAO.eliminar(id);
        vista.mostrarMensaje(ok ? "Animal eliminado." : "No se encontró el animal.");
        if (ok) RegistroLog.registrar("Animal eliminado id=" + id);
    }

    // =====================================================
    //  EMPLEADOS
    // =====================================================

    private void menuEmpleados() throws SQLException {
        boolean volver = false;
        while (!volver) {
            vista.mostrarMenuEmpleados();
            int op = vista.pedirEntero("Elige una opción");
            switch (op) {
                case 1: registrarEmpleado(); break;
                case 2: listarEmpleados(); break;
                case 3: editarEmpleado(); break;
                case 4: eliminarEmpleado(); break;
                case 0: volver = true; break;
                default: vista.mostrarMensaje("Opción no válida.");
            }
        }
    }

    private void registrarEmpleado() throws SQLException {
        vista.mostrarTitulo("Nuevo empleado");
        Empleado e = new Empleado();
        e.setNombre(ValidadorDatos.exigirTexto(vista.pedirTexto("Nombre"), "Nombre"));
        e.setRol(ValidadorDatos.exigirTexto(vista.pedirTexto("Rol"), "Rol"));
        e.setTelefono(ValidadorDatos.exigirTexto(vista.pedirTexto("Teléfono"), "Teléfono"));
        e.setFechaContratacion(ValidadorDatos.exigirFecha(
                vista.pedirTexto("Fecha de contratación (yyyy-MM-dd)"), "Fecha contratación"));
        int id = empleadoDAO.insertar(e);
        vista.mostrarMensaje("Empleado registrado con ID " + id);
        RegistroLog.registrar("Empleado registrado id=" + id + " (" + e.getNombre() + ")");
    }

    private void listarEmpleados() throws SQLException {
        vista.mostrarTitulo("Listado de empleados");
        List<Empleado> lista = empleadoDAO.listar();
        if (lista.isEmpty()) {
            vista.mostrarMensaje("No hay empleados registrados.");
            return;
        }
        for (Empleado e : lista) {
            vista.mostrarMensaje(e.toString());
        }
    }

    private void editarEmpleado() throws SQLException {
        int id = vista.pedirEntero("ID del empleado a editar");
        Empleado e = empleadoDAO.buscarPorId(id);
        if (e == null) {
            vista.mostrarMensaje("No existe un empleado con id=" + id);
            return;
        }
        vista.mostrarMensaje("Pulsa Intro para conservar el valor actual.");
        e.setNombre(noVacio(vista.pedirTexto("Nombre [" + e.getNombre() + "]"), e.getNombre()));
        e.setRol(noVacio(vista.pedirTexto("Rol [" + e.getRol() + "]"), e.getRol()));
        e.setTelefono(noVacio(vista.pedirTexto("Teléfono [" + e.getTelefono() + "]"), e.getTelefono()));
        e.setFechaContratacion(noVacio(
                vista.pedirTexto("Fecha contrato [" + e.getFechaContratacion() + "]"),
                e.getFechaContratacion()));
        boolean ok = empleadoDAO.actualizar(e);
        vista.mostrarMensaje(ok ? "Empleado actualizado." : "No se ha modificado nada.");
        if (ok) RegistroLog.registrar("Empleado editado id=" + id);
    }

    private void eliminarEmpleado() throws SQLException {
        int id = vista.pedirEntero("ID del empleado a eliminar");
        if (!vista.pedirConfirmacion("¿Confirmas el borrado?")) {
            return;
        }
        try {
            boolean ok = empleadoDAO.eliminar(id);
            vista.mostrarMensaje(ok ? "Empleado eliminado." : "No se encontró el empleado.");
            if (ok) RegistroLog.registrar("Empleado eliminado id=" + id);
        } catch (SQLException ex) {
            // Si tiene actividades asociadas, la FK no deja borrar.
            vista.mostrarError("No se puede eliminar: tiene actividades asociadas. "
                    + "Detalle BD: " + ex.getMessage());
        }
    }

    // =====================================================
    //  ACTIVIDADES
    // =====================================================

    private void menuActividades() throws SQLException {
        boolean volver = false;
        while (!volver) {
            vista.mostrarMenuActividades();
            int op = vista.pedirEntero("Elige una opción");
            switch (op) {
                case 1: registrarActividad(); break;
                case 2: listarActividades(); break;
                case 3: listarActividadesPorFecha(); break;
                case 4: eliminarActividad(); break;
                case 0: volver = true; break;
                default: vista.mostrarMensaje("Opción no válida.");
            }
        }
    }

    private void registrarActividad() throws SQLException {
        vista.mostrarTitulo("Nueva actividad");
        Actividad a = new Actividad();
        a.setFecha(ValidadorDatos.exigirFecha(
                vista.pedirTexto("Fecha (yyyy-MM-dd)"), "Fecha"));
        a.setHora(ValidadorDatos.exigirHora(
                vista.pedirTexto("Hora (HH:mm)"), "Hora"));
        TipoActividad tipo = vista.pedirTipoActividad();
        a.setTipo(tipo);
        a.setDescripcion(vista.pedirTexto("Descripción"));
        a.setIdEmpleado(vista.pedirEntero("ID del empleado responsable"));

        // Comprobamos que el empleado existe.
        if (empleadoDAO.buscarPorId(a.getIdEmpleado()) == null) {
            vista.mostrarError("No existe ese empleado.");
            return;
        }

        // Animales involucrados (opcionales).
        List<Integer> animales = vista.pedirListaEnteros("IDs de animales involucrados");
        a.setAnimales(animales);

        int id = actividadDAO.insertar(a);
        vista.mostrarMensaje("Actividad registrada con ID " + id);
        RegistroLog.registrar("Actividad registrada id=" + id + " tipo=" + tipo);
    }

    private void listarActividades() throws SQLException {
        vista.mostrarTitulo("Listado de actividades");
        List<Actividad> lista = actividadDAO.listar();
        if (lista.isEmpty()) {
            vista.mostrarMensaje("No hay actividades registradas.");
            return;
        }
        for (Actividad a : lista) {
            vista.mostrarMensaje(a.toString());
        }
    }

    private void listarActividadesPorFecha() throws SQLException {
        String fecha = ValidadorDatos.exigirFecha(
                vista.pedirTexto("Fecha (yyyy-MM-dd)"), "Fecha");
        List<Actividad> lista = actividadDAO.listarPorFecha(fecha);
        vista.mostrarTitulo("Actividades del " + fecha);
        if (lista.isEmpty()) {
            vista.mostrarMensaje("No hay actividades ese día.");
            return;
        }
        for (Actividad a : lista) {
            vista.mostrarMensaje(a.toString());
        }
    }

    private void eliminarActividad() throws SQLException {
        int id = vista.pedirEntero("ID de la actividad a eliminar");
        if (!vista.pedirConfirmacion("¿Confirmas el borrado?")) return;
        boolean ok = actividadDAO.eliminar(id);
        vista.mostrarMensaje(ok ? "Actividad eliminada." : "No se encontró la actividad.");
        if (ok) RegistroLog.registrar("Actividad eliminada id=" + id);
    }

    // =====================================================
    //  REPORTES
    // =====================================================

    private void menuReportes() throws SQLException {
        boolean volver = false;
        while (!volver) {
            vista.mostrarMenuReportes();
            int op = vista.pedirEntero("Elige una opción");
            switch (op) {
                case 1: reporteAnimalesPorEspecie(); break;
                case 2: listarActividadesPorFecha(); break;
                case 0: volver = true; break;
                default: vista.mostrarMensaje("Opción no válida.");
            }
        }
    }

    private void reporteAnimalesPorEspecie() throws SQLException {
        vista.mostrarTitulo("Animales por especie");
        List<String[]> filas = animalDAO.contarPorEspecie();
        if (filas.isEmpty()) {
            vista.mostrarMensaje("No hay animales registrados.");
            return;
        }
        vista.mostrarMensaje(String.format("%-20s %s", "ESPECIE", "TOTAL"));
        for (String[] f : filas) {
            vista.mostrarMensaje(String.format("%-20s %s", f[0], f[1]));
        }
    }

    // =====================================================
    //  COPIAS / EXPORTACIONES
    // =====================================================

    private void hacerCopiaSeguridad() throws Exception {
        Path destino = CopiaSeguridadUtil.generarCopia(
                animalDAO.listar(),
                empleadoDAO.listar(),
                actividadDAO.listar());
        vista.mostrarMensaje("Copia de seguridad creada en: " + destino.toAbsolutePath());
    }

    private void exportarExcel() throws Exception {
        Path destino = ExportadorExcel.exportar(
                animalDAO.listar(),
                empleadoDAO.listar(),
                actividadDAO.listar());
        vista.mostrarMensaje("Excel generado en: " + destino);
    }

    private void exportarPDF() throws Exception {
        Path destino = ExportadorPDF.exportar(
                animalDAO.listar(),
                empleadoDAO.listar(),
                actividadDAO.listar());
        vista.mostrarMensaje("PDF generado en: " + destino);
    }

    // =====================================================
    //  Helpers
    // =====================================================

    /** Si el usuario escribió en blanco, conserva el valor anterior. */
    private static String noVacio(String nuevo, String anterior) {
        return (nuevo == null || nuevo.isBlank()) ? anterior : nuevo.trim();
    }
}
