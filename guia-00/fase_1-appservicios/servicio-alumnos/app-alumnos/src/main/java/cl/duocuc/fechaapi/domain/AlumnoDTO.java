package cl.duocuc.fechaapi.domain;

/**
 * DTO de Alumno - Capa de dominio
 * Representa la estructura de datos para la API
 */
public class AlumnoDTO {

    private Long id;
    private String rut;
    private String nombre;
    private String apellido;

    public AlumnoDTO() {}

    public AlumnoDTO(Long id, String rut, String nombre, String apellido) {
        this.id = id;
        this.rut = rut;
        this.nombre = nombre;
        this.apellido = apellido;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRut() {
        return rut;
    }

    public void setRut(String rut) {
        this.rut = rut;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }
}
