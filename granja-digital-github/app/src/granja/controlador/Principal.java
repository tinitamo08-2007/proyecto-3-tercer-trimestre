package granja.controlador;

/**
 * Punto de entrada de la aplicación Granja Digital.
 *
 * Solo crea el ControladorGranja y le cede el control.
 */
public class Principal {

    public static void main(String[] args) {
        ControladorGranja controlador = new ControladorGranja();
        controlador.iniciar();
    }
}
