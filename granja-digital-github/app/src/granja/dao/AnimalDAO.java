package granja.dao;

import granja.modelo.Animal;
import granja.modelo.EstadoAnimal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO (Data Access Object) para la entidad Animal.
 *
 * Concentra todas las sentencias SQL relacionadas con la tabla "animal".
 * El controlador no toca JDBC nunca: siempre llama al DAO.
 */
public class AnimalDAO {

    private static final String SQL_INSERT =
            "INSERT INTO animal (especie, raza, fecha_nacimiento, identificador, "
            + "estado_salud, ubicacion, estado) VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_UPDATE =
            "UPDATE animal SET especie = ?, raza = ?, fecha_nacimiento = ?, "
            + "identificador = ?, estado_salud = ?, ubicacion = ?, estado = ? "
            + "WHERE id = ?";

    private static final String SQL_DELETE =
            "DELETE FROM animal WHERE id = ?";

    private static final String SQL_FIND_BY_ID =
            "SELECT id, especie, raza, fecha_nacimiento, identificador, "
            + "estado_salud, ubicacion, estado FROM animal WHERE id = ?";

    private static final String SQL_FIND_ALL =
            "SELECT id, especie, raza, fecha_nacimiento, identificador, "
            + "estado_salud, ubicacion, estado FROM animal ORDER BY id";

    private static final String SQL_CONTAR_POR_ESPECIE =
            "SELECT especie, COUNT(*) AS total FROM animal GROUP BY especie ORDER BY total DESC";

    /**
     * Inserta un nuevo animal y devuelve el ID generado.
     */
    public int insertar(Animal a) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {

            rellenar(ps, a);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    a.setId(rs.getInt(1));
                }
            }
            return a.getId();
        }
    }

    /**
     * Actualiza un animal existente. Devuelve true si se modificó alguna fila.
     */
    public boolean actualizar(Animal a) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_UPDATE)) {

            rellenar(ps, a);
            ps.setInt(8, a.getId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Elimina el animal con el ID indicado.
     */
    public boolean eliminar(int id) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_DELETE)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Devuelve un animal por su ID, o null si no existe.
     */
    public Animal buscarPorId(int id) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_ID)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? leer(rs) : null;
            }
        }
    }

    /**
     * Devuelve la lista completa de animales.
     */
    public List<Animal> listar() throws SQLException {
        List<Animal> lista = new ArrayList<>();
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(leer(rs));
            }
        }
        return lista;
    }

    /**
     * Cuenta cuántos animales hay por especie.
     * Devuelve una lista de pares "especie / total".
     */
    public List<String[]> contarPorEspecie() throws SQLException {
        List<String[]> lista = new ArrayList<>();
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_CONTAR_POR_ESPECIE);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(new String[] { rs.getString("especie"),
                                          String.valueOf(rs.getInt("total")) });
            }
        }
        return lista;
    }

    // ===== Helpers privados =====

    private void rellenar(PreparedStatement ps, Animal a) throws SQLException {
        ps.setString(1, a.getEspecie());
        ps.setString(2, a.getRaza());
        ps.setString(3, a.getFechaNacimiento());
        ps.setString(4, a.getIdentificador());
        ps.setString(5, a.getEstadoSalud());
        ps.setString(6, a.getUbicacion());
        ps.setString(7, a.getEstado().name());
    }

    private Animal leer(ResultSet rs) throws SQLException {
        Animal a = new Animal();
        a.setId(rs.getInt("id"));
        a.setEspecie(rs.getString("especie"));
        a.setRaza(rs.getString("raza"));
        a.setFechaNacimiento(rs.getString("fecha_nacimiento"));
        a.setIdentificador(rs.getString("identificador"));
        a.setEstadoSalud(rs.getString("estado_salud"));
        a.setUbicacion(rs.getString("ubicacion"));
        String estado = rs.getString("estado");
        a.setEstado(estado != null ? EstadoAnimal.valueOf(estado) : EstadoAnimal.ACTIVO);
        return a;
    }
}
