package granja.excepciones;

/**
 * Excepción para cuando el usuario introduce un dato que no cumple las reglas:
 * fecha mal formada, número negativo donde no debe, identificador vacío...
 *
 * Hereda de RuntimeException para no obligar a declararla en cada método; es
 * el patrón habitual cuando la excepción representa un error de uso y no un
 * fallo recuperable del sistema.
 */
public class DatoInvalidoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public DatoInvalidoException(String mensaje) {
        super(mensaje);
    }

    public DatoInvalidoException(String mensaje, Throwable causa) {
        super(mensaje, causa);
    }
}
