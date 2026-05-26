package cl.duocuc.fechaapi.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AlumnoTest {

    @Test
    void testAlumnoConstructor() {
        // Given
        String rut = "12345678-9";
        String nombre = "Juan";
        String apellido = "Pérez";

        // When
        Alumno alumno = new Alumno(rut, nombre, apellido);

        // Then
        assertNotNull(alumno);
        assertEquals(rut, alumno.getRut());
        assertEquals(nombre, alumno.getNombre());
        assertEquals(apellido, alumno.getApellido());
    }

    @Test
    void testAlumnoSetters() {
        // Given
        Alumno alumno = new Alumno();

        // When
        alumno.setRut("12345678-9");
        alumno.setNombre("Juan");
        alumno.setApellido("Pérez");
        alumno.setId(1L);

        // Then
        assertEquals("12345678-9", alumno.getRut());
        assertEquals("Juan", alumno.getNombre());
        assertEquals("Pérez", alumno.getApellido());
        assertEquals(1L, alumno.getId());
    }

    @Test
    void testAlumnoDTOConstructor() {
        // Given
        Long id = 1L;
        String rut = "12345678-9";
        String nombre = "Juan";
        String apellido = "Pérez";

        // When
        AlumnoDTO dto = new AlumnoDTO(id, rut, nombre, apellido);

        // Then
        assertNotNull(dto);
        assertEquals(id, dto.getId());
        assertEquals(rut, dto.getRut());
        assertEquals(nombre, dto.getNombre());
        assertEquals(apellido, dto.getApellido());
    }

    @Test
    void testAlumnoDTOSetters() {
        // Given
        AlumnoDTO dto = new AlumnoDTO();

        // When
        dto.setId(1L);
        dto.setRut("12345678-9");
        dto.setNombre("Juan");
        dto.setApellido("Pérez");

        // Then
        assertEquals(1L, dto.getId());
        assertEquals("12345678-9", dto.getRut());
        assertEquals("Juan", dto.getNombre());
        assertEquals("Pérez", dto.getApellido());
    }
}
