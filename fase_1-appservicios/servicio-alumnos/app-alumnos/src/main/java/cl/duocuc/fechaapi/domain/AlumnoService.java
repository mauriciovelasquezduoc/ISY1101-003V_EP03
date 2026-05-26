package cl.duocuc.fechaapi.domain;

import java.util.List;
import java.util.Optional;

/**
 * Servicio de Alumno - Capa de dominio
 * Contiene la lógica de negocio para la entidad Alumno
 */
public interface AlumnoService {

    List<Alumno> getAllAlumnos();

    Optional<Alumno> getAlumnoById(Long id);

    Optional<Alumno> getAlumnoByRut(String rut);

    Alumno createAlumno(Alumno alumno);

    Alumno updateAlumno(Long id, Alumno alumno);

    void deleteAlumno(Long id);
}
