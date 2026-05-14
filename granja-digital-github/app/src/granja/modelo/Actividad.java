package granja.modelo;

import java.util.ArrayList;
import java.util.List;

/**
 * Representa una actividad realizada en la granja.
 *
 * Una actividad esta vinculada a un empleado responsable (idEmpleado) y
 * puede involucrar a cero, uno o varios animales (relacion N:M con animal,
 * resuelta en BD con la tabla intermedia "actividad_animal").
 */
public class Actividad {

    private int id;                  // ID interno
    private String fecha;            // Fecha en formato yyyy-MM-dd
    private String hora;             // Hora en formato HH:mm
    private TipoActividad tipo;      // Tipo enumerado
    private String descripcion;      // Texto libre opcional
    private int idEmpleado;          // FK al empleado responsable

    /** IDs de los animales involucrados (puede estar vacia). */
    private List<Integer> animales = new ArrayList<>();

    // ===== Constructores =====

    public Actividad() {
    }

    public Actividad(int id, String fecha, String hora, TipoActividad tipo,
                     String descripcion, int idEmpleado) {
        this.id = id;
        this.fecha = fecha;
        this.hora = hora;
        this.tipo = tipo;
        this.descripcion = descripcion;
        this.idEmpleado = idEmpleado;
    }

    // ===== Getters y setters =====

    public int getId()                       { return id; }
    public void setId(int id)                { this.id = id; }

    public String getFecha()                 { return fecha; }
    public void setFecha(String fecha)       { this.fecha = fecha; }

    public String getHora()                  { return hora; }
    public void setHora(String hora)         { this.hora = hora; }

    public TipoActividad getTipo()                { return tipo; }
    public void setTipo(TipoActividad tipo)       { this.tipo = tipo; }

    public String getDescripcion()                 { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public int getIdEmpleado()               { return idEmpleado; }
    public void setIdEmpleado(int id)        { this.idEmpleado = id; }

    public List<Integer> getAnimales()                 { return animales; }
    public void setAnimales(List<Integer> animales)    {
        this.animales = animales != null ? animales : new ArrayList<>();
    }

    @Override
    public String toString() {
        return String.format(
                "[%3d] %s %s  Tipo:%-12s  Empleado:%d  Desc:\"%s\"  Animales:%s",
                id,
                nz(fecha),
                nz(hora),
                tipo,
                idEmpleado,
                nz(descripcion),
                animales);
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
