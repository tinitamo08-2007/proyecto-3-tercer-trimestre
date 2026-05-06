package granja.modelo;

/**
 * Representa un animal registrado en la granja.
 * Esta clase solo almacena datos, no tiene lógica compleja.
 */
public class Animal {

    private int id;                                     // Identificador interno del animal (lo usaremos como "id" numérico).
    private String especie;                             // Especie del animal (vaca, oveja, cerdo, etc.).
    private String raza;                                // Raza de la especie (Holstein, Merina, etc.).
    private String fechaNacimiento;                     // Fecha de nacimiento en formato texto (ej: "2020-05-01").
    private String identificador;                       // Identificador único físico (ej: arete, chip).
    private String estadoSalud;                         // Estado de salud (ej: "buena", "grave", "crítica").
    private String ubicacion;                           // Ubicación actual (corral 1, potrero norte, etc.).
    private EstadoAnimal estado = EstadoAnimal.ACTIVO;  // Estado general dentro de la granja (ACTIVO, VENDIDO, etc.).

    // ==== Getters y setters ====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        // Aquí podrías validar que no sea negativo.
        this.id = id;
    }

    public String getEspecie() {
        return especie;
    }

    public void setEspecie(String especie) {
        this.especie = especie;
    }

    public String getRaza() {
        return raza;
    }

    public void setRaza(String raza) {
        this.raza = raza;
    }

    public String getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(String fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public String getIdentificador() {
        return identificador;
    }

    public void setIdentificador(String identificador) {
        this.identificador = identificador;
    }

    public String getEstadoSalud() {
        return estadoSalud;
    }

    public void setEstadoSalud(String estadoSalud) {
        this.estadoSalud = estadoSalud;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public EstadoAnimal getEstado() {
        return estado;
    }

    public void setEstado(EstadoAnimal estado) {
        this.estado = estado;
    }

    /**
     * Devuelve una representación de texto del animal, usada al imprimirlo por consola.
     */
    @Override
    public String toString() {
        return "Animal{" +
                "id=" + id +
                ", especie='" + especie + '\'' +
                ", raza='" + raza + '\'' +
                ", fechaNacimiento='" + fechaNacimiento + '\'' +
                ", identificador='" + identificador + '\'' +
                ", estadoSalud='" + estadoSalud + '\'' +
                ", ubicacion='" + ubicacion + '\'' +
                ", estado=" + estado +
                '}';
    }
}