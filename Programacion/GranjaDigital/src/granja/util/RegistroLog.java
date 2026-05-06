package granja.utilidades;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;

/**
 * Clase de utilidad para registrar mensajes en un archivo de texto.
 * No depende de base de datos, solo de ficheros.
 */
public class RegistroLog {

    // Ruta del archivo de log (lo creará en la carpeta "registros" cuando exista).
    private static final String ARCHIVO_LOG = "registros/aplicacion.log";

    /**
     * Escribe una línea en el log con fecha y hora.
     */
    public static void registrar(String mensaje) {
        try (PrintWriter out = new PrintWriter(new FileWriter(ARCHIVO_LOG, true))) {
            out.printf("%s - %s%n", LocalDateTime.now(), mensaje);
        } catch (IOException e) {
            System.err.println("Error al escribir en el log: " + e.getMessage());
        }
    }
}