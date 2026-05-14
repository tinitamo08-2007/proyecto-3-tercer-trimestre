package granja.vista;

import granja.modelo.EstadoAnimal;
import granja.modelo.TipoActividad;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Scanner;

/**
 * Vista de consola.
 *
 * Es la unica clase que habla con System.in / System.out. Recibe datos del
 * usuario, los valida formalmente (que no sea texto donde se pide un numero,
 * por ejemplo) y los devuelve al controlador. Nunca contiene logica de negocio.
 */
public class VistaConsola {

    /** Scanner unico para leer desde teclado. */
    private final Scanner sc = new Scanner(System.in);

    // =========================================================
    //  Lectura de datos
    // =========================================================

    /** Pide un numero entero, repitiendo hasta que el usuario lo escribe bien. */
    public int pedirEntero(String mensaje) {
        while (true) {
            System.out.print(mensaje + ": ");
            String linea = sc.nextLine();
            try {
                return Integer.parseInt(linea.trim());
            } catch (NumberFormatException e) {
                System.out.println("  Debes introducir un numero entero.");
            }
        }
    }

    /** Pide una cadena (acepta vacia). */
    public String pedirTexto(String mensaje) {
        System.out.print(mensaje + ": ");
        return sc.nextLine().trim();
    }

    /** Pide confirmacion (s/n) y devuelve true si el usuario contesta si. */
    public boolean pedirConfirmacion(String mensaje) {
        while (true) {
            System.out.print(mensaje + " (s/n): ");
            String r = sc.nextLine().trim().toLowerCase();
            if (r.equals("s") || r.equals("si")) return true;
            if (r.equals("n") || r.equals("no")) return false;
            System.out.println("  Responde con 's' o 'n'.");
        }
    }

    /** Pide una lista de enteros separados por coma. Vacio = lista vacia. */
    public List<Integer> pedirListaEnteros(String mensaje) {
        String linea = pedirTexto(mensaje + " (vacio para ninguno, separados por coma)");
        if (linea.isBlank()) {
            return Collections.emptyList();
        }
        try {
            return Arrays.stream(linea.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Integer::parseInt)
                    .toList();
        } catch (NumberFormatException e) {
            System.out.println("  Lista invalida, se ignorara.");
            return Collections.emptyList();
        }
    }

    // =========================================================
    //  Menus
    // =========================================================

    public void mostrarMenuPrincipal() {
        linea();
        System.out.println("  GRANJA DIGITAL - MENU PRINCIPAL");
        linea();
        System.out.println("  1. Gestion de animales");
        System.out.println("  2. Gestion de empleados");
        System.out.println("  3. Registro de actividades");
        System.out.println("  4. Reportes");
        System.out.println("  5. Generar copia de seguridad (CSV)");
        System.out.println("  6. Exportar a Excel");
        System.out.println("  7. Exportar a PDF");
        System.out.println("  0. Salir");
        linea();
    }

    public void mostrarMenuAnimales() {
        sublinea();
        System.out.println("  ANIMALES");
        sublinea();
        System.out.println("  1. Registrar nuevo animal");
        System.out.println("  2. Listar animales");
        System.out.println("  3. Buscar animal por ID");
        System.out.println("  4. Editar animal");
        System.out.println("  5. Cambiar estado (vendido / fallecido / trasladado)");
        System.out.println("  6. Eliminar animal");
        System.out.println("  0. Volver");
    }

    public void mostrarMenuEmpleados() {
        sublinea();
        System.out.println("  EMPLEADOS");
        sublinea();
        System.out.println("  1. Registrar empleado");
        System.out.println("  2. Listar empleados");
        System.out.println("  3. Editar empleado");
        System.out.println("  4. Eliminar empleado");
        System.out.println("  0. Volver");
    }

    public void mostrarMenuActividades() {
        sublinea();
        System.out.println("  ACTIVIDADES");
        sublinea();
        System.out.println("  1. Registrar actividad");
        System.out.println("  2. Listar todas las actividades");
        System.out.println("  3. Listar actividades de una fecha");
        System.out.println("  4. Eliminar actividad");
        System.out.println("  0. Volver");
    }

    public void mostrarMenuReportes() {
        sublinea();
        System.out.println("  REPORTES");
        sublinea();
        System.out.println("  1. Animales agrupados por especie");
        System.out.println("  2. Actividades por fecha");
        System.out.println("  0. Volver");
    }

    /** Pide al usuario un estado de animal mediante un numero. */
    public EstadoAnimal pedirEstadoAnimal() {
        System.out.println("Estado del animal:");
        System.out.println("  1. ACTIVO");
        System.out.println("  2. VENDIDO");
        System.out.println("  3. FALLECIDO");
        System.out.println("  4. TRASLADADO");
        int opcion = pedirEntero("Opcion");
        switch (opcion) {
            case 2: return EstadoAnimal.VENDIDO;
            case 3: return EstadoAnimal.FALLECIDO;
            case 4: return EstadoAnimal.TRASLADADO;
            default: return EstadoAnimal.ACTIVO;
        }
    }

    /** Pide al usuario un tipo de actividad. */
    public TipoActividad pedirTipoActividad() {
        System.out.println("Tipo de actividad:");
        System.out.println("  1. ORDENIE (ordene)");
        System.out.println("  2. ALIMENTACION");
        System.out.println("  3. VACUNACION");
        System.out.println("  4. LIMPIEZA");
        System.out.println("  5. OTRA");
        int opcion = pedirEntero("Opcion");
        switch (opcion) {
            case 1: return TipoActividad.ORDENIE;
            case 2: return TipoActividad.ALIMENTACION;
            case 3: return TipoActividad.VACUNACION;
            case 4: return TipoActividad.LIMPIEZA;
            default: return TipoActividad.OTRA;
        }
    }

    // =========================================================
    //  Salidas
    // =========================================================

    public void mostrarMensaje(String mensaje) {
        System.out.println(mensaje);
    }

    public void mostrarError(String mensaje) {
        System.err.println("[ERROR] " + mensaje);
    }

    public void mostrarTitulo(String titulo) {
        sublinea();
        System.out.println("  " + titulo);
        sublinea();
    }

    private void linea() {
        System.out.println("=================================================");
    }

    private void sublinea() {
        System.out.println("-------------------------------------------------");
    }
}
