package granja.dao;

import granja.util.RegistroLog;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Gestiona la conexión JDBC con la base de datos MySQL.
 *
 * Lee la configuración desde el archivo {@code config.properties} situado en
 * la raíz del proyecto. Si no encuentra el archivo, utiliza valores por
 * defecto pensados para el entorno típico de XAMPP / MySQL local.
 *
 * Patrón: la clase abre una nueva Connection por petición (no se cachea).
 * Para un proyecto con concurrencia se usaría un pool tipo HikariCP, pero
 * para un proyecto de aula esta solución es la más sencilla y clara.
 */
public class ConexionBD {

    /** Ruta del archivo de configuración respecto al directorio de ejecución. */
    private static final Path RUTA_CONFIG = Path.of("config.properties");

    private static final String URL_POR_DEFECTO =
            "jdbc:mysql://localhost:3306/granja_digital?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USUARIO_POR_DEFECTO = "root";
    private static final String CLAVE_POR_DEFECTO = "root";

    private static Properties configCache;

    private ConexionBD() {
        // Clase utilitaria, no instanciable.
    }

    /**
     * Abre una nueva conexión con la base de datos.
     * La debe cerrar el llamador con try-with-resources.
     */
    public static Connection abrir() throws SQLException {
        Properties cfg = cargarConfig();
        String url = cfg.getProperty("db.url", URL_POR_DEFECTO);
        String usuario = cfg.getProperty("db.usuario", USUARIO_POR_DEFECTO);
        String clave = cfg.getProperty("db.clave", CLAVE_POR_DEFECTO);
        try {
            return DriverManager.getConnection(url, usuario, clave);
        } catch (SQLException e) {
            RegistroLog.error("No se pudo abrir conexión con la BD: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Comprueba si la conexión funciona; devuelve true/false sin lanzar
     * excepción, útil para mostrar al inicio si la BD está disponible.
     */
    public static boolean probarConexion() {
        try (Connection c = abrir()) {
            return c != null && !c.isClosed();
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * Carga (y cachea) las propiedades del archivo config.properties.
     */
    private static synchronized Properties cargarConfig() {
        if (configCache != null) {
            return configCache;
        }
        Properties p = new Properties();
        if (Files.exists(RUTA_CONFIG)) {
            try (InputStream in = new FileInputStream(RUTA_CONFIG.toFile())) {
                p.load(in);
            } catch (IOException e) {
                RegistroLog.advertencia("No se pudo leer config.properties: " + e.getMessage());
            }
        } else {
            RegistroLog.advertencia(
                    "No se encontró config.properties. Se usarán valores por defecto "
                    + "(usuario=root, clave=root, url localhost).");
        }
        configCache = p;
        return p;
    }
}
