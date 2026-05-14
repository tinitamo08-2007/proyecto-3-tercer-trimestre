package granja.util;

import granja.modelo.Actividad;
import granja.modelo.Animal;
import granja.modelo.Empleado;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;

/**
 * Genera archivos CSV como copia de seguridad de los datos.
 *
 * Se crea un archivo por entidad (animales, empleados, actividades) con la
 * fecha de hoy en el nombre, de forma que se puedan tener respaldos diarios
 * sin sobreescribirse.
 */
public class CopiaSeguridadUtil {

    /** Carpeta donde se guardan las copias. */
    private static final Path CARPETA_COPIAS = Path.of("copias");

    private CopiaSeguridadUtil() {
        // Clase utilitaria.
    }

    /**
     * Genera tres ficheros CSV (animales, empleados, actividades) con el
     * estado actual de la granja.
     *
     * @return Ruta de la carpeta donde se han escrito las copias.
     */
    public static Path generarCopia(List<Animal> animales,
                                    List<Empleado> empleados,
                                    List<Actividad> actividades) throws IOException {

        Files.createDirectories(CARPETA_COPIAS);

        String fecha = LocalDate.now().toString();
        Path archivoAnimales = CARPETA_COPIAS.resolve("animales_" + fecha + ".csv");
        Path archivoEmpleados = CARPETA_COPIAS.resolve("empleados_" + fecha + ".csv");
        Path archivoActividades = CARPETA_COPIAS.resolve("actividades_" + fecha + ".csv");

        // === Animales ===
        try (FileWriter fw = new FileWriter(archivoAnimales.toFile())) {
            fw.write("id,especie,raza,fecha_nacimiento,identificador,estado_salud,ubicacion,estado\n");
            if (animales != null) {
                for (Animal a : animales) {
                    fw.write(a.getId() + ","
                            + escape(a.getEspecie()) + ","
                            + escape(a.getRaza()) + ","
                            + escape(a.getFechaNacimiento()) + ","
                            + escape(a.getIdentificador()) + ","
                            + escape(a.getEstadoSalud()) + ","
                            + escape(a.getUbicacion()) + ","
                            + a.getEstado() + "\n");
                }
            }
        }

        // === Empleados ===
        try (FileWriter fw = new FileWriter(archivoEmpleados.toFile())) {
            fw.write("id,nombre,rol,telefono,fecha_contratacion\n");
            if (empleados != null) {
                for (Empleado e : empleados) {
                    fw.write(e.getId() + ","
                            + escape(e.getNombre()) + ","
                            + escape(e.getRol()) + ","
                            + escape(e.getTelefono()) + ","
                            + escape(e.getFechaContratacion()) + "\n");
                }
            }
        }

        // === Actividades ===
        try (FileWriter fw = new FileWriter(archivoActividades.toFile())) {
            fw.write("id,fecha,hora,tipo,descripcion,id_empleado\n");
            if (actividades != null) {
                for (Actividad ac : actividades) {
                    fw.write(ac.getId() + ","
                            + escape(ac.getFecha()) + ","
                            + escape(ac.getHora()) + ","
                            + ac.getTipo() + ","
                            + escape(ac.getDescripcion()) + ","
                            + ac.getIdEmpleado() + "\n");
                }
            }
        }

        RegistroLog.registrar("Copia de seguridad generada en " + CARPETA_COPIAS.toAbsolutePath());
        return CARPETA_COPIAS;
    }

    /**
     * Escapa un valor para CSV: si contiene coma, comillas o salto de linea
     * se rodea de comillas y se duplican las comillas internas.
     */
    private static String escape(String texto) {
        if (texto == null) {
            return "";
        }
        boolean necesitaComillas = texto.contains(",")
                || texto.contains("\"")
                || texto.contains("\n");
        String t = texto.replace("\"", "\"\"");
        return necesitaComillas ? "\"" + t + "\"" : t;
    }
}
