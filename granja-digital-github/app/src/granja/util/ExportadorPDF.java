package granja.util;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import granja.modelo.Actividad;
import granja.modelo.Animal;
import granja.modelo.Empleado;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Exporta el estado actual de la granja a un archivo PDF usando iText 5.
 *
 * El documento incluye una portada con la fecha y tres tablas: animales,
 * empleados y actividades.
 */
public class ExportadorPDF {

    private static final Path CARPETA = Path.of("copias");

    /** Color verde "campo" para las cabeceras de tabla. */
    private static final BaseColor VERDE_CABECERA = new BaseColor(46, 125, 50);

    private ExportadorPDF() {
        // Clase utilitaria.
    }

    /**
     * Genera un PDF con la información de la granja.
     *
     * @return Ruta absoluta del PDF generado.
     */
    public static Path exportar(List<Animal> animales,
                                List<Empleado> empleados,
                                List<Actividad> actividades) throws IOException {

        Files.createDirectories(CARPETA);
        Path destino = CARPETA.resolve("granja_" + LocalDate.now() + ".pdf");

        Document documento = new Document(PageSize.A4);
        try (FileOutputStream fos = new FileOutputStream(destino.toFile())) {
            PdfWriter.getInstance(documento, fos);
            documento.open();

            // ===== Portada / encabezado =====
            Font titulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, VERDE_CABECERA);
            Paragraph p = new Paragraph("Informe Granja Digital", titulo);
            p.setAlignment(Element.ALIGN_CENTER);
            documento.add(p);

            Font normal = FontFactory.getFont(FontFactory.HELVETICA, 10, BaseColor.DARK_GRAY);
            Paragraph subt = new Paragraph(
                    "Generado: " + LocalDateTime.now().format(
                            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")),
                    normal);
            subt.setAlignment(Element.ALIGN_CENTER);
            subt.setSpacingAfter(15);
            documento.add(subt);

            // ===== Animales =====
            seccion(documento, "Animales (" + animales.size() + ")");
            PdfPTable tA = nuevaTabla(8);
            cabeceras(tA, "ID", "Especie", "Raza", "Fecha nac.",
                    "Identificador", "Salud", "Ubicación", "Estado");
            for (Animal a : animales) {
                celda(tA, String.valueOf(a.getId()));
                celda(tA, nz(a.getEspecie()));
                celda(tA, nz(a.getRaza()));
                celda(tA, nz(a.getFechaNacimiento()));
                celda(tA, nz(a.getIdentificador()));
                celda(tA, nz(a.getEstadoSalud()));
                celda(tA, nz(a.getUbicacion()));
                celda(tA, a.getEstado().name());
            }
            documento.add(tA);

            // ===== Empleados =====
            seccion(documento, "Empleados (" + empleados.size() + ")");
            PdfPTable tE = nuevaTabla(5);
            cabeceras(tE, "ID", "Nombre", "Rol", "Teléfono", "Contratación");
            for (Empleado e : empleados) {
                celda(tE, String.valueOf(e.getId()));
                celda(tE, nz(e.getNombre()));
                celda(tE, nz(e.getRol()));
                celda(tE, nz(e.getTelefono()));
                celda(tE, nz(e.getFechaContratacion()));
            }
            documento.add(tE);

            // ===== Actividades =====
            seccion(documento, "Actividades (" + actividades.size() + ")");
            PdfPTable tAct = nuevaTabla(6);
            cabeceras(tAct, "ID", "Fecha", "Hora", "Tipo", "Descripción", "ID empleado");
            for (Actividad ac : actividades) {
                celda(tAct, String.valueOf(ac.getId()));
                celda(tAct, nz(ac.getFecha()));
                celda(tAct, nz(ac.getHora()));
                celda(tAct, ac.getTipo().name());
                celda(tAct, nz(ac.getDescripcion()));
                celda(tAct, String.valueOf(ac.getIdEmpleado()));
            }
            documento.add(tAct);

            documento.close();
        } catch (DocumentException e) {
            throw new IOException("Error al generar el PDF: " + e.getMessage(), e);
        }

        RegistroLog.registrar("Exportado PDF en " + destino.toAbsolutePath());
        return destino.toAbsolutePath();
    }

    // ===== Helpers de maquetación =====

    private static void seccion(Document doc, String texto) throws DocumentException {
        Font f = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, VERDE_CABECERA);
        Paragraph p = new Paragraph(texto, f);
        p.setSpacingBefore(10);
        p.setSpacingAfter(6);
        doc.add(p);
    }

    private static PdfPTable nuevaTabla(int columnas) throws DocumentException {
        PdfPTable t = new PdfPTable(columnas);
        t.setWidthPercentage(100);
        return t;
    }

    private static void cabeceras(PdfPTable tabla, String... textos) {
        Font f = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, BaseColor.WHITE);
        for (String texto : textos) {
            PdfPCell c = new PdfPCell(new Phrase(texto, f));
            c.setBackgroundColor(VERDE_CABECERA);
            c.setPadding(4);
            tabla.addCell(c);
        }
    }

    private static void celda(PdfPTable tabla, String texto) {
        Font f = FontFactory.getFont(FontFactory.HELVETICA, 9, BaseColor.BLACK);
        PdfPCell c = new PdfPCell(new Phrase(texto, f));
        c.setPadding(3);
        tabla.addCell(c);
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
