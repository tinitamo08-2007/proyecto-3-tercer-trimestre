package granja.vista;

import granja.modelo.EstadoAnimal;
import granja.modelo.TipoActividad;

import java.util.Scanner;

/**
 * Vista de consola.
 * Encargada de mostrar menús y leer datos del usuario.
 */
public class VistaConsola {

    // Scanner único para leer desde teclado.
    private final Scanner sc = new Scanner(System.in);

    /**
     * Pide un número entero al usuario, validando que no escriba letras.
     */
    public int pedirEntero(String mensaje) {
        while (true) {
            System.out.print(mensaje + ": ");
            String linea = sc.nextLine();
            try {
                return Integer.parseInt(linea);
            } catch (NumberFormatException e) {
                System.out.println("Debes introducir un número entero.");
            }
        }
    }

    /**
     * Pide una cadena de texto al usuario.
     */
    public String pedirTexto(String mensaje) {
        System.out.print(mensaje + ": ");
        return sc.nextLine().trim();
    }

    // ==== Menús ====

    public void mostrarMenuPrincipal() {
        System.out.println("\n=== MENÚ PRINCIPAL ===");
        System.out.println("1. Gestión de animales");
        System.out.println("2. Gestión de empleados");
        System.out.println("3. Registro de actividades");
        System.out.println("4. Generar copia de seguridad");
        System.out.println("0. Salir");
    }

    public void mostrarMenuAnimales() {
        System.out.println("\n--- ANIMALES ---");
        System.out.println("1. Registrar nuevo animal");
        System.out.println("2. Listar animales");
        System.out.println("3. Editar estado de salud");
        System.out.println("4. Eliminar animal");
        System.out.println("0. Volver");
    }

    public void mostrarMenuEmpleados() {
        System.out.println("\n--- EMPLEADOS ---");
        System.out.println("1. Registrar empleado");
        System.out.println("2. Listar empleados");
        System.out.println("0. Volver");
    }

    public void mostrarMenuActividades() {
        System.out.println("\n--- ACTIVIDADES ---");
        System.out.println("1. Registrar actividad");
        System.out.println("2. Listar actividades");
        System.out.println("0. Volver");
    }

    /**
     * Pide al usuario un estado de animal (enum) mediante un número.
     */
    public EstadoAnimal pedirEstadoAnimal() {
        System.out.println("Estado del animal:");
        System.out.println("1. ACTIVO");
        System.out.println("2. VENDIDO");
        System.out.println("3. FALLECIDO");
        System.out.println("4. TRASLADADO");
        int opcion = pedirEntero("Opción");
        switch (opcion) {
            case 2: return EstadoAnimal.VENDIDO;
            case 3: return EstadoAnimal.FALLECIDO;
            case 4: return EstadoAnimal.TRASLADADO;
            default: return EstadoAnimal.ACTIVO;
        }
    }

    /**
     * Pide al usuario un tipo de actividad (enum).
     */
    public TipoActividad pedirTipoActividad() {
        System.out.println("Tipo de actividad:");
        System.out.println("1. ORDENIE");
        System.out.println("2. ALIMENTACIÓN");
        System.out.println("3. VACUNACIÓN");
        System.out.println("4. LIMPIEZA");
        System.out.println("5. OTRA");
        int opcion = pedirEntero("Opción");
        switch (opcion) {
            case 1: return TipoActividad.ORDENIE;
            case 2: return TipoActividad.ALIMENTACION;
            case 3: return TipoActividad.VACUNACION;
            case 4: return TipoActividad.LIMPIEZA;
            default: return TipoActividad.OTRA;
        }
    }
}