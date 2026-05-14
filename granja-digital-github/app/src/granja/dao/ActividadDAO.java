package granja.dao;

import granja.modelo.Actividad;
import granja.modelo.TipoActividad;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Actividad.
 *
 * Gestiona también la relación N:M con animal (tabla "actividad_animal").
 * Cuando insertamos una actividad con animales asociados, lo hacemos en una
 * sola transacción: primero el INSERT en actividad, después los INSERTs en
 * actividad_animal. Si algo falla, se hace rollback.
 */
public class ActividadDAO {

    private static final String SQL_INSERT =
            "INSERT INTO actividad (fecha, hora, tipo, descripcion, id_empleado) "
            + "VALUES (?, ?, ?, ?, ?)";

    private static final String SQL_INSERT_REL =
            "INSERT INTO actividad_animal (id_actividad, id_animal) VALUES (?, ?)";

    private static final String SQL_DELETE_REL =
            "DELETE FROM actividad_animal WHERE id_actividad = ?";

    private static final String SQL_FIND_REL =
            "SELECT id_animal FROM actividad_animal WHERE id_actividad = ?";

    private static final String SQL_FIND_ALL =
            "SELECT id, fecha, hora, tipo, descripcion, id_empleado "
            + "FROM actividad ORDER BY fecha DESC, hora DESC";

    private static final String SQL_FIND_BY_FECHA =
            "SELECT id, fecha, hora, tipo, descripcion, id_empleado "
            + "FROM actividad WHERE fecha = ? ORDER BY hora";

    private static final String SQL_DELETE =
            "DELETE FROM actividad WHERE id = ?";

    /**
     * Inserta una actividad y sus animales asociados en una transacción.
     */
    public int insertar(Actividad a) throws SQLException {
        try (Connection con = ConexionBD.abrir()) {
            con.setAutoCommit(false);
            try {
                int id;
                try (PreparedStatement ps = con.prepareStatement(
                        SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, a.getFecha());
                    ps.setString(2, a.getHora());
                    ps.setString(3, a.getTipo().name());
                    ps.setString(4, a.getDescripcion());
                    ps.setInt(5, a.getIdEmpleado());
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) {
                            throw new SQLException("No se pudo obtener el ID de la nueva actividad.");
                        }
                        id = rs.getInt(1);
                    }
                }

                // Insertar los animales asociados
                if (a.getAnimales() != null && !a.getAnimales().isEmpty()) {
                    try (PreparedStatement ps = con.prepareStatement(SQL_INSERT_REL)) {
                        for (Integer idAnimal : a.getAnimales()) {
                            ps.setInt(1, id);
                            ps.setInt(2, idAnimal);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }

                con.commit();
                a.setId(id);
                return id;
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /**
     * Borra una actividad (y sus filas en actividad_animal por ON DELETE CASCADE).
     */
    public boolean eliminar(int id) throws SQLException {
        try (Connection con = ConexionBD.abrir()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(SQL_DELETE_REL)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                int n;
                try (PreparedStatement ps = con.prepareStatement(SQL_DELETE)) {
                    ps.setInt(1, id);
                    n = ps.executeUpdate();
                }
                con.commit();
                return n > 0;
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    /**
     * Lista todas las actividades. Cada Actividad incluye la lista de animales.
     */
    public List<Actividad> listar() throws SQLException {
        List<Actividad> lista = new ArrayList<>();
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Actividad a = leer(rs);
                a.setAnimales(animalesDe(con, a.getId()));
                lista.add(a);
            }
        }
        return lista;
    }

    /**
     * Devuelve las actividades de un día concreto (yyyy-MM-dd).
     */
    public List<Actividad> listarPorFecha(String fecha) throws SQLException {
        List<Actividad> lista = new ArrayList<>();
        try (Connection con = ConexionBD.abrir();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_FECHA)) {

            ps.setString(1, fecha);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Actividad a = leer(rs);
                    a.setAnimales(animalesDe(con, a.getId()));
                    lista.add(a);
                }
            }
        }
        return lista;
    }

    /**
     * Recupera los IDs de animales asociados a la actividad indicada.
     */
    private List<Integer> animalesDe(Connection con, int idActividad) throws SQLException {
        List<Integer> ids = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(SQL_FIND_REL)) {
            ps.setInt(1, idActividad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
        }
        return ids;
    }

    private Actividad leer(ResultSet rs) throws SQLException {
        Actividad a = new Actividad();
        a.setId(rs.getInt("id"));
        a.setFecha(rs.getString("fecha"));
        a.setHora(rs.getString("hora"));
        a.setTipo(TipoActividad.valueOf(rs.getString("tipo")));
        a.setDescripcion(rs.getString("descripcion"));
        a.setIdEmpleado(rs.getInt("id_empleado"));
        return a;
    }
}
