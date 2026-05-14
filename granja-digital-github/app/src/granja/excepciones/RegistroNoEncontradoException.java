package granja.excepciones;

/**
 * Excepción para cuando se pide un registro (animal, empleado, actividad...)
 * por ID y no existe en la base de datos.
 */
public class RegistroNoEncontradoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public RegistroNoEncontradoException(String mensaje) {
        super(mensaje);
    }

    public RegistroNoEncontradoException(String entidad, int id) {
        super("No se ha encontrado " + entidad + " con id=" + id);
    }
}
