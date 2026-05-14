package granja.dao;

import granja.modelo.Empleado;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Empleado. CRUD + listado por rol y empleados más activos.
 */
public class EmpleadoDAO {

    private static final String SQL_INSERT =
            "INSERT INTO empleado (nombre, rol, telefono, fecha_contratacion) "
            + "VALUES (?, ?, ?, ?)";

    private static final String SQL_UPDATE =
            "UPDATE empleado SET nombre = ?, rol = ?, telefono = ?, "
            + "fecha_contratacion = ? WHERE id = ?";

    private static final String SQL_DELETE =
            "DELETE FROM empleado WHERE id = ?";

    private static final String SQL_FIND_BY_ID =
            "SELECT id, nombre, rol, telefono, fecha_contratacion "
            + "FROM empleado WHERE id = ?";

    private static final String SQL_FIND_ALL =
            "SELECT id, nombre, rol, telefono, fecha_contratacion "
            + "FROM empleado ORDER BY id";

    public int insertar(Empleado e) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {

            rellenar(ps, e);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    e.setId(rs.getInt(1));
                }
            }
            return e.getId();
        }
    }

    public boolean actualizar(Empleado e) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_UPDATE)) {

            rellenar(ps, e);
            ps.setInt(5, e.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_DELETE)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public Empleado buscarPorId(int id) throws SQLException {
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_ID)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? leer(rs) : null;
            }
        }
    }

    public List<Empleado> listar() throws SQLException {
        List<Empleado> lista = new ArrayList<>();
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(leer(rs));
            }
        }
        return lista;
    }

    private void rellenar(PreparedStatement ps, Empleado e) throws SQLException {
        ps.setString(1, e.getNombre());
        ps.setString(2, e.getRol());
        ps.setString(3, e.getTelefono());
        ps.setString(4, e.getFechaContratacion());
    }

    private Empleado leer(ResultSet rs) throws SQLException {
        Empleado e = new Empleado();
        e.setId(rs.getInt("id"));
        e.setNombre(rs.getString("nombre"));
        e.setRol(rs.getString("rol"));
        e.setTelefono(rs.getString("telefono"));
        e.setFechaContratacion(rs.getString("fecha_contratacion"));
        return e;
    }
}
