package cl.duocuc.fechaapi.infrastructure.persistence;

import cl.duocuc.fechaapi.domain.Alumno;
import jakarta.persistence.*;

/**
 * Entidad de persistencia de Alumno
 * Mapea la entidad Alumno a la base de datos
 */
@Entity
@Table(name = "duoc_alumnos")
public class AlumnoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rut", nullable = false, unique = true)
    private String rut;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false)
    private String apellido;

    public AlumnoEntity() {}

    public AlumnoEntity(Long id, String rut, String nombre, String apellido) {
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

    public static AlumnoEntity fromDomain(Alumno alumno) {
        if (alumno == null) return null;
        return new AlumnoEntity(
            alumno.getId(),
            alumno.getRut(),
            alumno.getNombre(),
            alumno.getApellido()
        );
    }

    public static Alumno toDomain(AlumnoEntity entity) {
        if (entity == null) return null;
        Alumno alumno = new Alumno();
        alumno.setId(entity.getId());
        alumno.setRut(entity.getRut());
        alumno.setNombre(entity.getNombre());
        alumno.setApellido(entity.getApellido());
        return alumno;
    }
}
