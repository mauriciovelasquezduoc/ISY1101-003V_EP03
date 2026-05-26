package cl.duocuc.fechaapi.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio JPA de Alumno
 * Interfaz para operaciones de persistencia con Spring Data JPA
 */
@Repository
public interface AlumnoJpaRepository extends JpaRepository<AlumnoEntity, Long> {

    Optional<AlumnoEntity> findByRut(String rut);
}
