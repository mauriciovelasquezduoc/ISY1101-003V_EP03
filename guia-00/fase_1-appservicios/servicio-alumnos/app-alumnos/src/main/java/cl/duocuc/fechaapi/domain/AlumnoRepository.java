package cl.duocuc.fechaapi.domain;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio de Alumno - Capa de dominio
 * Define las operaciones CRUD para la entidad Alumno
 */
public interface AlumnoRepository {

    List<Alumno> findAll();

    Optional<Alumno> findById(Long id);

    Alumno findByRut(String rut);

    Alumno save(Alumno alumno);

    void deleteById(Long id);
}
