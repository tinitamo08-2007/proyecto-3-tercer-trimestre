package granja.util;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Clase de utilidad para registrar mensajes en un archivo de texto (log).
 *
 * Se escriben tanto las acciones normales del sistema (alta de animales,
 * empleados, copias de seguridad...) como los errores capturados.
 *
 * Se utiliza desde un único punto para asegurar la trazabilidad.
 */
public class RegistroLog {

    /** Ruta relativa del archivo de log. Se crea si no existe. */
    private static final Path ARCHIVO_LOG = Path.of("registros", "aplicacion.log");

    private static final DateTimeFormatter FORMATO_FECHA =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /** Usuario actual del sistema (se actualiza al iniciar sesion). */
    private static String usuarioActual = "anonimo";

    private RegistroLog() {
        // Clase utilitaria, no se instancia.
    }

    /**
     * Asigna el usuario activo para que aparezca en cada linea del log.
     */
    public static void setUsuarioActual(String usuario) {
        if (usuario != null && !usuario.isBlank()) {
            usuarioActual = usuario;
        }
    }

    /**
     * Escribe una linea informativa en el log con fecha, hora y usuario.
     */
    public static void registrar(String mensaje) {
        escribir("INFO", mensaje);
    }

    /** Escribe una linea con nivel ERROR. */
    public static void error(String mensaje) {
        escribir("ERROR", mensaje);
    }

    /** Escribe una linea con nivel WARN (advertencia). */
    public static void advertencia(String mensaje) {
        escribir("WARN", mensaje);
    }

    /**
     * Implementacion interna: asegura que existe la carpeta y escribe la linea.
     */
    private static void escribir(String nivel, String mensaje) {
        try {
            if (ARCHIVO_LOG.getParent() != null) {
                Files.createDirectories(ARCHIVO_LOG.getParent());
            }
            try (PrintWriter out = new PrintWriter(
                    new FileWriter(ARCHIVO_LOG.toFile(), true))) {
                out.printf("%s [%s] (%s) - %s%n",
                        LocalDateTime.now().format(FORMATO_FECHA),
                        nivel,
                        usuarioActual,
                        mensaje);
            }
        } catch (IOException e) {
            System.err.println("Error al escribir en el log: " + e.getMessage());
        }
    }
}
