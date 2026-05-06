package granja.utilidades;

import granja.modelo.Animal;
import granja.modelo.Actividad;

import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Genera archivos CSV como copia de seguridad de los datos en memoria.
 */
public class CopiaSeguridadUtil {

    /**
     * Genera dos ficheros CSV:
     *  - uno con los animales,
     *  - otro con las actividades.
     *
     * Usa las listas que le pasamos como parámetros.
     */
    public static void generarCopia(List<Animal> animales, List<Actividad> actividades) {
        String fecha = LocalDate.now().toString();
        String archivoAnimales = "copias/animales_" + fecha + ".csv";
        String archivoActividades = "copias/actividades_" + fecha + ".csv";

        try {
            // Escribir animales
            try (FileWriter fw = new FileWriter(archivoAnimales)) {
                fw.write("id,especie,raza,fecha_nacimiento,identificador,estado_salud,ubicacion,estado\n");
                for (Animal a : animales) {
                    fw.write(a.getId() + "," +
                             a.getEspecie() + "," +
                             a.getRaza() + "," +
                             a.getFechaNacimiento() + "," +
                             a.getIdentificador() + "," +
                             a.getEstadoSalud() + "," +
                             a.getUbicacion() + "," +
                             a.getEstado() + "\n");
                }
            }

            // Escribir actividades
            try (FileWriter fw = new FileWriter(archivoActividades)) {
                fw.write("id,fecha,hora,tipo,descripcion,id_empleado\n");
                for (Actividad ac : actividades) {
                    fw.write(ac.getId() + "," +
                             ac.getFecha() + "," +
                             ac.getHora() + "," +
                             ac.getTipo() + "," +
                             ac.getDescripcion() + "," +
                             ac.getIdEmpleado() + "\n");
                }
            }

            RegistroLog.registrar("Copia de seguridad generada correctamente (en memoria)");

            System.out.println("Copia de seguridad generada en carpeta 'copias' (cuando la crees).");

        } catch (IOException e) {
            System.err.println("Error al escribir la copia de seguridad: " + e.getMessage());
        }
    }
}