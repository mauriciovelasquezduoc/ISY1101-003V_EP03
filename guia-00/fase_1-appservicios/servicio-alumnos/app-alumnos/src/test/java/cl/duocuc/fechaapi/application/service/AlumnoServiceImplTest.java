package cl.duocuc.fechaapi.application.service;

import cl.duocuc.fechaapi.domain.Alumno;
import cl.duocuc.fechaapi.domain.AlumnoRepository;
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

class AlumnoServiceImplTest {

    @Mock
    private AlumnoRepository alumnoRepository;

    @InjectMocks
    private AlumnoServiceImpl alumnoService;

    private Alumno alumno1;
    private Alumno alumno2;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        alumno1 = new Alumno("12345678-9", "Juan", "Pérez");
        alumno1.setId(1L);
        alumno2 = new Alumno("23456789-0", "María", "González");
        alumno2.setId(2L);
    }

    @Test
    void testGetAllAlumnos() {
        // Given
        when(alumnoRepository.findAll()).thenReturn(List.of(alumno1, alumno2));

        // When
        List<Alumno> alumnos = alumnoService.getAllAlumnos();

        // Then
        assertNotNull(alumnos);
        assertEquals(2, alumnos.size());
        verify(alumnoRepository, times(1)).findAll();
    }

    @Test
    void testGetAlumnoByIdFound() {
        // Given
        when(alumnoRepository.findById(1L)).thenReturn(Optional.of(alumno1));

        // When
        Optional<Alumno> resultado = alumnoService.getAlumnoById(1L);

        // Then
        assertTrue(resultado.isPresent());
        assertEquals(alumno1.getId(), resultado.get().getId());
        verify(alumnoRepository, times(1)).findById(1L);
    }

    @Test
    void testGetAlumnoByIdNotFound() {
        // Given
        when(alumnoRepository.findById(99L)).thenReturn(Optional.empty());

        // When
        Optional<Alumno> resultado = alumnoService.getAlumnoById(99L);

        // Then
        assertFalse(resultado.isPresent());
        verify(alumnoRepository, times(1)).findById(99L);
    }

    @Test
    void testGetAlumnoByRutFound() {
        // Given
        when(alumnoRepository.findByRut("12345678-9")).thenReturn(alumno1);

        // When
        Optional<Alumno> resultado = alumnoService.getAlumnoByRut("12345678-9");

        // Then
        assertTrue(resultado.isPresent());
        assertEquals("12345678-9", resultado.get().getRut());
        verify(alumnoRepository, times(1)).findByRut("12345678-9");
    }

    @Test
    void testGetAlumnoByRutNotFound() {
        // Given
        when(alumnoRepository.findByRut("99999999-9")).thenReturn(null);

        // When
        Optional<Alumno> resultado = alumnoService.getAlumnoByRut("99999999-9");

        // Then
        assertFalse(resultado.isPresent());
        verify(alumnoRepository, times(1)).findByRut("99999999-9");
    }

    @Test
    void testCreateAlumno() {
        // Given
        when(alumnoRepository.save(any(Alumno.class))).thenReturn(alumno1);

        // When
        Alumno creado = alumnoService.createAlumno(alumno1);

        // Then
        assertNotNull(creado);
        assertEquals("12345678-9", creado.getRut());
        verify(alumnoRepository, times(1)).save(alumno1);
    }

    @Test
    void testUpdateAlumnoFound() {
        // Given
        Alumno alumnoActualizado = new Alumno("12345678-9", "Juan", "Rodríguez");
        alumnoActualizado.setId(1L);
        when(alumnoRepository.findById(1L)).thenReturn(Optional.of(alumno1));
        when(alumnoRepository.save(any(Alumno.class))).thenReturn(alumnoActualizado);

        // When
        Alumno resultado = alumnoService.updateAlumno(1L, alumnoActualizado);

        // Then
        assertNotNull(resultado);
        assertEquals("Rodríguez", resultado.getApellido());
        verify(alumnoRepository, times(1)).findById(1L);
        verify(alumnoRepository, times(1)).save(any(Alumno.class));
    }

    @Test
    void testUpdateAlumnoNotFound() {
        // Given
        when(alumnoRepository.findById(99L)).thenReturn(Optional.empty());

        // When
        Alumno resultado = alumnoService.updateAlumno(99L, alumno1);

        // Then
        assertNull(resultado);
        verify(alumnoRepository, times(1)).findById(99L);
        verify(alumnoRepository, never()).save(any(Alumno.class));
    }

    @Test
    void testDeleteAlumno() {
        // Given
        when(alumnoRepository.findById(1L)).thenReturn(Optional.of(alumno1));

        // When
        alumnoService.deleteAlumno(1L);

        // Then
        verify(alumnoRepository, times(1)).deleteById(1L);
    }
}
