/**
 * Módulo de la aplicación GranjaDigital.
 *
 * IMPORTANTE:
 *  - Si Eclipse marca errores en los "requires" de abajo, significa que aún
 *    no se han copiado los JAR a la carpeta lib/. Mira el README.md de la raíz.
 *  - Si prefieres no usar el sistema de módulos, puedes dejar el archivo así:
 *        module GranjaDigital { }
 *    o eliminarlo y configurar todo el lib/ como Classpath en Eclipse.
 */
module GranjaDigital {

    // ===== Módulos del JDK =====
    requires java.sql;              // API JDBC
    requires java.desktop;          // por si añadimos GUI Swing/JavaFX en el futuro

    // ===== Librerías externas (módulos automáticos desde lib/) =====
    requires mysql.connector.j;     // Driver MySQL
    requires org.apache.poi.poi;    // Apache POI base
    requires org.apache.poi.ooxml;  // Apache POI para .xlsx
    requires itextpdf;              // iText 5 para PDFs
}
