package granja.modelo;

/**
 * Representa una actividad realizada en la granja.
 */
public class Actividad {

    private int id;              // ID interno
    private String fecha;        // Fecha de la actividad
    private String hora;         // Hora de la actividad
    private TipoActividad tipo;  // Tipo de actividad (enum)
    private String descripcion;  // Descripción opcional
    private int idEmpleado;      // ID del empleado responsable

    // ==== Getters y setters ====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public String getHora() {
        return hora;
    }

    public void setHora(String hora) {
        this.hora = hora;
    }

    public TipoActividad getTipo() {
        return tipo;
    }

    public void setTipo(TipoActividad tipo) {
        this.tipo = tipo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public int getIdEmpleado() {
        return idEmpleado;
    }

    public void setIdEmpleado(int idEmpleado) {
        this.idEmpleado = idEmpleado;
    }

    @Override
    public String toString() {
        return "Actividad{" +
                "id=" + id +
                ", fecha='" + fecha + '\'' +
                ", hora='" + hora + '\'' +
                ", tipo=" + tipo +
                ", descripcion='" + descripcion + '\'' +
                ", idEmpleado=" + idEmpleado +
                '}';
    }
}