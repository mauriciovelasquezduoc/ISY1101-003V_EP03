package cl.duocuc.fechaapi.infrastructure.repository;

import cl.duocuc.fechaapi.domain.Alumno;
import cl.duocuc.fechaapi.domain.AlumnoRepository;
import cl.duocuc.fechaapi.infrastructure.persistence.AlumnoEntity;
import cl.duocuc.fechaapi.infrastructure.persistence.AlumnoJpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Implementación del repositorio de Alumno - Capa de infraestructura
 * Usa Spring Data JPA para la persistencia
 */
@Repository
@Transactional
public class AlumnoRepositoryImpl implements AlumnoRepository {

    private final AlumnoJpaRepository alumnoJpaRepository;

    public AlumnoRepositoryImpl(AlumnoJpaRepository alumnoJpaRepository) {
        this.alumnoJpaRepository = alumnoJpaRepository;
    }

    @Override
    public List<Alumno> findAll() {
        return alumnoJpaRepository.findAll().stream()
            .map(AlumnoEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public Optional<Alumno> findById(Long id) {
        return alumnoJpaRepository.findById(id)
            .map(AlumnoEntity::toDomain);
    }

    @Override
    public Alumno findByRut(String rut) {
        return alumnoJpaRepository.findByRut(rut)
            .map(AlumnoEntity::toDomain)
            .orElse(null);
    }

    @Override
    public Alumno save(Alumno alumno) {
        AlumnoEntity entity = AlumnoEntity.fromDomain(alumno);
        AlumnoEntity saved = alumnoJpaRepository.save(entity);
        return AlumnoEntity.toDomain(saved);
    }

    @Override
    public void deleteById(Long id) {
        alumnoJpaRepository.deleteById(id);
    }
}
