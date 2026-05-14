package granja.modelo;

/**
 * Representa a un empleado de la granja.
 *
 * Cada empleado puede ser responsable de varias actividades; la relacion se
 * gestiona en la tabla "actividad" mediante una clave foranea a esta entidad.
 */
public class Empleado {

    private int id;                   // ID autogenerado por la BD
    private String nombre;            // Nombre completo
    private String rol;               // veterinario, peon, encargado...
    private String telefono;          // Telefono de contacto
    private String fechaContratacion; // Fecha en formato yyyy-MM-dd

    // ===== Constructores =====

    public Empleado() {
    }

    public Empleado(int id, String nombre, String rol, String telefono,
                    String fechaContratacion) {
        this.id = id;
        this.nombre = nombre;
        this.rol = rol;
        this.telefono = telefono;
        this.fechaContratacion = fechaContratacion;
    }

    // ===== Getters y setters =====

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public String getNombre()                   { return nombre; }
    public void setNombre(String nombre)        { this.nombre = nombre; }

    public String getRol()                      { return rol; }
    public void setRol(String rol)              { this.rol = rol; }

    public String getTelefono()                 { return telefono; }
    public void setTelefono(String telefono)    { this.telefono = telefono; }

    public String getFechaContratacion()                    { return fechaContratacion; }
    public void setFechaContratacion(String fechaContrato)  { this.fechaContratacion = fechaContrato; }

    @Override
    public String toString() {
        return String.format(
                "[%3d] %-25s  Rol: %-12s  Tel: %-12s  Contrato: %s",
                id,
                nz(nombre),
                nz(rol),
                nz(telefono),
                nz(fechaContratacion));
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
