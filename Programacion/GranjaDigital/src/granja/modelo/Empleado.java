package granja.modelo;

/**
 * Representa a un empleado de la granja.
 */
public class Empleado {

    private int id;                 // ID interno (número)
    private String nombre;          // Nombre completo
    private String rol;             // Rol en la granja (veterinario, peón, encargado...)
    private String telefono;        // Teléfono de contacto
    private String fechaContratacion; // Fecha de contratación

    // ==== Getters y setters ====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getFechaContratacion() {
        return fechaContratacion;
    }

    public void setFechaContratacion(String fechaContratacion) {
        this.fechaContratacion = fechaContratacion;
    }

    @Override
    public String toString() {
        return "Empleado{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", rol='" + rol + '\'' +
                ", telefono='" + telefono + '\'' +
                ", fechaContratacion='" + fechaContratacion + '\'' +
                '}';
    }
}