package granja.controlador;

import granja.controlador.ControladorGranja;

/**
 * Punto de entrada de la aplicación.
 */
public class Principal {

    public static void main(String[] args) {
        // Creamos el controlador principal y lanzamos el sistema.
        ControladorGranja controlador = new ControladorGranja();
        controlador.iniciar();
    }
}