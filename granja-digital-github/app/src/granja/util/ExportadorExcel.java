package granja.util;

import granja.modelo.Actividad;
import granja.modelo.Animal;
import granja.modelo.Empleado;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;

/**
 * Exporta el estado actual de la granja a un archivo Excel (.xlsx) usando
 * Apache POI.
 *
 * El libro tiene tres hojas: Animales, Empleados y Actividades, cada una con
 * la cabecera en negrita y las columnas autoajustadas.
 */
public class ExportadorExcel {

    /** Carpeta donde se vuelcan los Excel exportados. */
    private static final Path CARPETA = Path.of("copias");

    private ExportadorExcel() {
        // Clase utilitaria.
    }

    /**
     * Genera un archivo .xlsx con tres hojas (animales, empleados, actividades).
     *
     * @return Ruta absoluta del archivo creado.
     */
    public static Path exportar(List<Animal> animales,
                                List<Empleado> empleados,
                                List<Actividad> actividades) throws IOException {

        Files.createDirectories(CARPETA);
        Path destino = CARPETA.resolve("granja_" + LocalDate.now() + ".xlsx");

        try (Workbook wb = new XSSFWorkbook();
             FileOutputStream fos = new FileOutputStream(destino.toFile())) {

            CellStyle cabecera = crearEstiloCabecera(wb);

            // ===== Hoja de animales =====
            Sheet hojaA = wb.createSheet("Animales");
            String[] colsA = {"ID", "Especie", "Raza", "Fecha nacimiento",
                    "Identificador", "Estado salud", "Ubicación", "Estado"};
            escribirCabecera(hojaA, colsA, cabecera);
            int fila = 1;
            for (Animal a : animales) {
                Row r = hojaA.createRow(fila++);
                r.createCell(0).setCellValue(a.getId());
                r.createCell(1).setCellValue(nz(a.getEspecie()));
                r.createCell(2).setCellValue(nz(a.getRaza()));
                r.createCell(3).setCellValue(nz(a.getFechaNacimiento()));
                r.createCell(4).setCellValue(nz(a.getIdentificador()));
                r.createCell(5).setCellValue(nz(a.getEstadoSalud()));
                r.createCell(6).setCellValue(nz(a.getUbicacion()));
                r.createCell(7).setCellValue(a.getEstado().name());
            }
            autoajustar(hojaA, colsA.length);

            // ===== Hoja de empleados =====
            Sheet hojaE = wb.createSheet("Empleados");
            String[] colsE = {"ID", "Nombre", "Rol", "Teléfono", "Fecha contratación"};
            escribirCabecera(hojaE, colsE, cabecera);
            fila = 1;
            for (Empleado e : empleados) {
                Row r = hojaE.createRow(fila++);
                r.createCell(0).setCellValue(e.getId());
                r.createCell(1).setCellValue(nz(e.getNombre()));
                r.createCell(2).setCellValue(nz(e.getRol()));
                r.createCell(3).setCellValue(nz(e.getTelefono()));
                r.createCell(4).setCellValue(nz(e.getFechaContratacion()));
            }
            autoajustar(hojaE, colsE.length);

            // ===== Hoja de actividades =====
            Sheet hojaAct = wb.createSheet("Actividades");
            String[] colsAct = {"ID", "Fecha", "Hora", "Tipo", "Descripción", "ID empleado"};
            escribirCabecera(hojaAct, colsAct, cabecera);
            fila = 1;
            for (Actividad ac : actividades) {
                Row r = hojaAct.createRow(fila++);
                r.createCell(0).setCellValue(ac.getId());
                r.createCell(1).setCellValue(nz(ac.getFecha()));
                r.createCell(2).setCellValue(nz(ac.getHora()));
                r.createCell(3).setCellValue(ac.getTipo().name());
                r.createCell(4).setCellValue(nz(ac.getDescripcion()));
                r.createCell(5).setCellValue(ac.getIdEmpleado());
            }
            autoajustar(hojaAct, colsAct.length);

            wb.write(fos);
        }

        RegistroLog.registrar("Exportado Excel en " + destino.toAbsolutePath());
        return destino.toAbsolutePath();
    }

    private static CellStyle crearEstiloCabecera(Workbook wb) {
        Font negrita = wb.createFont();
        negrita.setBold(true);
        negrita.setColor(IndexedColors.WHITE.getIndex());
        CellStyle estilo = wb.createCellStyle();
        estilo.setFont(negrita);
        estilo.setFillForegroundColor(IndexedColors.DARK_GREEN.getIndex());
        estilo.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return estilo;
    }

    private static void escribirCabecera(Sheet hoja, String[] columnas, CellStyle estilo) {
        Row cab = hoja.createRow(0);
        for (int i = 0; i < columnas.length; i++) {
            Cell c = cab.createCell(i);
            c.setCellValue(columnas[i]);
            c.setCellStyle(estilo);
        }
    }

    private static void autoajustar(Sheet hoja, int columnas) {
        for (int i = 0; i < columnas; i++) {
            hoja.autoSizeColumn(i);
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
