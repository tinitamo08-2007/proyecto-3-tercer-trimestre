package granja.modelo;

/**
 * Representa un animal registrado en la granja.
 *
 * Es una clase de datos (POJO): atributos privados, getters/setters,
 * y un toString() para mostrar el animal por consola.
 */
public class Animal {

    private int id;                                     // ID interno autogenerado por la base de datos (AUTO_INCREMENT).
    private String especie;                             // Especie del animal (vaca, oveja, cerdo, gallina...).
    private String raza;                                // Raza concreta (Holstein, Merina, Duroc...).
    private String fechaNacimiento;                     // Fecha de nacimiento en formato ISO yyyy-MM-dd.
    private String identificador;                       // Identificador unico fisico (arete, chip, anilla...).
    private String estadoSalud;                         // Estado de salud: "buena", "regular", "grave", "critica".
    private String ubicacion;                           // Ubicacion: corral 1, potrero norte, etc.
    private EstadoAnimal estado = EstadoAnimal.ACTIVO;  // Estado dentro de la granja (ACTIVO, VENDIDO, FALLECIDO, TRASLADADO).

    // ===== Constructores =====

    public Animal() {
    }

    public Animal(int id, String especie, String raza, String fechaNacimiento,
                  String identificador, String estadoSalud, String ubicacion,
                  EstadoAnimal estado) {
        this.id = id;
        this.especie = especie;
        this.raza = raza;
        this.fechaNacimiento = fechaNacimiento;
        this.identificador = identificador;
        this.estadoSalud = estadoSalud;
        this.ubicacion = ubicacion;
        this.estado = estado != null ? estado : EstadoAnimal.ACTIVO;
    }

    // ===== Getters y setters =====

    public int getId()                       { return id; }
    public void setId(int id)                { this.id = id; }

    public String getEspecie()               { return especie; }
    public void setEspecie(String especie)   { this.especie = especie; }

    public String getRaza()                  { return raza; }
    public void setRaza(String raza)         { this.raza = raza; }

    public String getFechaNacimiento()                 { return fechaNacimiento; }
    public void setFechaNacimiento(String fechaNac)    { this.fechaNacimiento = fechaNac; }

    public String getIdentificador()              { return identificador; }
    public void setIdentificador(String ident)    { this.identificador = ident; }

    public String getEstadoSalud()                 { return estadoSalud; }
    public void setEstadoSalud(String estadoSalud) { this.estadoSalud = estadoSalud; }

    public String getUbicacion()             { return ubicacion; }
    public void setUbicacion(String ubic)    { this.ubicacion = ubic; }

    public EstadoAnimal getEstado()              { return estado; }
    public void setEstado(EstadoAnimal estado)   { this.estado = estado; }

    /**
     * Representacion tabular para mostrar por consola.
     */
    @Override
    public String toString() {
        return String.format(
                "[%3d] %-10s %-12s  Nac: %-10s  ID:%-8s  Salud:%-8s  Ubic:%-12s  Estado:%s",
                id,
                nz(especie),
                nz(raza),
                nz(fechaNacimiento),
                nz(identificador),
                nz(estadoSalud),
                nz(ubicacion),
                estado);
    }

    /** Devuelve el texto o cadena vacia si es null. */
    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
