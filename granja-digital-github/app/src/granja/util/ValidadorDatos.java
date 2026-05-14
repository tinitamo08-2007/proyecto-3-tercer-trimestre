package granja.util;

import granja.excepciones.DatoInvalidoException;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

/**
 * Métodos estáticos para validar las entradas del usuario.
 *
 * Lanzan DatoInvalidoException cuando algo no cumple las reglas, de modo que
 * el controlador puede capturarlas en un único punto y mostrar el mensaje
 * por consola.
 */
public class ValidadorDatos {

    private ValidadorDatos() {
        // Clase utilitaria.
    }

    /**
     * Comprueba que una cadena no es nula ni está en blanco.
     */
    public static String exigirTexto(String valor, String nombreCampo) {
        if (valor == null || valor.isBlank()) {
            throw new DatoInvalidoException("El campo '" + nombreCampo + "' no puede estar vacío.");
        }
        return valor.trim();
    }

    /**
     * Comprueba que la fecha tiene formato ISO yyyy-MM-dd y existe.
     */
    public static String exigirFecha(String fecha, String nombreCampo) {
        exigirTexto(fecha, nombreCampo);
        try {
            LocalDate.parse(fecha);
        } catch (DateTimeParseException e) {
            throw new DatoInvalidoException(
                    "La fecha '" + fecha + "' (" + nombreCampo + ") no es válida. "
                    + "Use el formato yyyy-MM-dd, por ejemplo 2024-09-15.");
        }
        return fecha;
    }

    /**
     * Comprueba que la hora tiene formato HH:mm.
     */
    public static String exigirHora(String hora, String nombreCampo) {
        exigirTexto(hora, nombreCampo);
        try {
            LocalTime.parse(hora);
        } catch (DateTimeParseException e) {
            throw new DatoInvalidoException(
                    "La hora '" + hora + "' (" + nombreCampo + ") no es válida. "
                    + "Use el formato HH:mm, por ejemplo 08:30.");
        }
        return hora;
    }

    /**
     * Comprueba que un entero está dentro de un rango.
     */
    public static int exigirEntero(int valor, int minimo, int maximo, String nombreCampo) {
        if (valor < minimo || valor > maximo) {
            throw new DatoInvalidoException(
                    "El campo '" + nombreCampo + "' debe estar entre "
                    + minimo + " y " + maximo + " (valor recibido: " + valor + ").");
        }
        return valor;
    }
}
