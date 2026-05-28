package cl.duocuc.fechaapi.infrastructure.repository;

import cl.duocuc.fechaapi.domain.Alumno;
import cl.duocuc.fechaapi.infrastructure.persistence.AlumnoEntity;
import cl.duocuc.fechaapi.infrastructure.persistence.AlumnoJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AlumnoRepositoryImplTest {

    @Mock
    private AlumnoJpaRepository alumnoJpaRepository;

    @InjectMocks
    private AlumnoRepositoryImpl alumnoRepository;

    private AlumnoEntity entity1;
    private AlumnoEntity entity2;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        entity1 = new AlumnoEntity(1L, "12345678-9", "Juan", "Pérez");
        entity2 = new AlumnoEntity(2L, "23456789-0", "María", "González");
    }

    @Test
    void testFindAll() {
        // Given
        when(alumnoJpaRepository.findAll()).thenReturn(List.of(entity1, entity2));

        // When
        List<Alumno> alumnos = alumnoRepository.findAll();

        // Then
        assertNotNull(alumnos);
        assertEquals(2, alumnos.size());
        assertEquals("12345678-9", alumnos.get(0).getRut());
        verify(alumnoJpaRepository, times(1)).findAll();
    }

    @Test
    void testFindById() {
        // Given
        when(alumnoJpaRepository.findById(1L)).thenReturn(Optional.of(entity1));

        // When
        Optional<Alumno> alumno = alumnoRepository.findById(1L);

        // Then
        assertTrue(alumno.isPresent());
        assertEquals(1L, alumno.get().getId());
        verify(alumnoJpaRepository, times(1)).findById(1L);
    }

    @Test
    void testFindByRut() {
        // Given
        when(alumnoJpaRepository.findByRut("12345678-9")).thenReturn(Optional.of(entity1));

        // When
        Alumno alumno = alumnoRepository.findByRut("12345678-9");

        // Then
        assertNotNull(alumno);
        assertEquals("12345678-9", alumno.getRut());
        verify(alumnoJpaRepository, times(1)).findByRut("12345678-9");
    }

    @Test
    void testSave() {
        // Given
        Alumno alumno = new Alumno("12345678-9", "Juan", "Pérez");
        alumno.setId(1L);
        when(alumnoJpaRepository.save(any(AlumnoEntity.class))).thenReturn(entity1);

        // When
        Alumno resultado = alumnoRepository.save(alumno);

        // Then
        assertNotNull(resultado);
        assertEquals("12345678-9", resultado.getRut());
        verify(alumnoJpaRepository, times(1)).save(any(AlumnoEntity.class));
    }

    @Test
    void testDeleteById() {
        // When
        alumnoRepository.deleteById(1L);

        // Then
        verify(alumnoJpaRepository, times(1)).deleteById(1L);
    }
}
