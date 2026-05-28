package cl.duocuc.fechaapi.application.service;

import cl.duocuc.fechaapi.domain.Alumno;
import cl.duocuc.fechaapi.domain.AlumnoRepository;
import cl.duocuc.fechaapi.domain.AlumnoService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de Alumno - Capa de aplicación
 * Coordina las operaciones entre el repositorio y el dominio
 */
@Service
public class AlumnoServiceImpl implements AlumnoService {

    private final AlumnoRepository alumnoRepository;

    public AlumnoServiceImpl(AlumnoRepository alumnoRepository) {
        this.alumnoRepository = alumnoRepository;
    }

    @Override
    public List<Alumno> getAllAlumnos() {
        return alumnoRepository.findAll();
    }

    @Override
    public Optional<Alumno> getAlumnoById(Long id) {
        return alumnoRepository.findById(id);
    }

    @Override
    public Optional<Alumno> getAlumnoByRut(String rut) {
        Alumno alumno = alumnoRepository.findByRut(rut);
        return Optional.ofNullable(alumno);
    }

    @Override
    public Alumno createAlumno(Alumno alumno) {
        return alumnoRepository.save(alumno);
    }

    @Override
    public Alumno updateAlumno(Long id, Alumno alumno) {
        Optional<Alumno> existing = alumnoRepository.findById(id);
        if (existing.isPresent()) {
            Alumno alumnoExistente = existing.get();
            alumnoExistente.setRut(alumno.getRut());
            alumnoExistente.setNombre(alumno.getNombre());
            alumnoExistente.setApellido(alumno.getApellido());
            return alumnoRepository.save(alumnoExistente);
        }
        return null;
    }

    @Override
    public void deleteAlumno(Long id) {
        alumnoRepository.deleteById(id);
    }
}
