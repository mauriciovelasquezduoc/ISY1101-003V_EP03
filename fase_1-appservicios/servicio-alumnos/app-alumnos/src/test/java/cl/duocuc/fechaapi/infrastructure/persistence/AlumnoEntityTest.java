package cl.duocuc.fechaapi.infrastructure.persistence;

import cl.duocuc.fechaapi.domain.Alumno;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AlumnoEntityTest {

    @Test
    void testFromDomain() {
        // Given
        Alumno alumno = new Alumno("12345678-9", "Juan", "Pérez");
        alumno.setId(1L);

        // When
        AlumnoEntity entity = AlumnoEntity.fromDomain(alumno);

        // Then
        assertNotNull(entity);
        assertEquals(1L, entity.getId());
        assertEquals("12345678-9", entity.getRut());
        assertEquals("Juan", entity.getNombre());
        assertEquals("Pérez", entity.getApellido());
    }

    @Test
    void testFromDomainNull() {
        // Given
        Alumno alumno = null;

        // When
        AlumnoEntity entity = AlumnoEntity.fromDomain(alumno);

        // Then
        assertNull(entity);
    }

    @Test
    void testToDomain() {
        // Given
        AlumnoEntity entity = new AlumnoEntity();
        entity.setId(1L);
        entity.setRut("12345678-9");
        entity.setNombre("Juan");
        entity.setApellido("Pérez");

        // When
        Alumno alumno = AlumnoEntity.toDomain(entity);

        // Then
        assertNotNull(alumno);
        assertEquals(1L, alumno.getId());
        assertEquals("12345678-9", alumno.getRut());
        assertEquals("Juan", alumno.getNombre());
        assertEquals("Pérez", alumno.getApellido());
    }

    @Test
    void testToDomainNull() {
        // Given
        AlumnoEntity entity = null;

        // When
        Alumno alumno = AlumnoEntity.toDomain(entity);

        // Then
        assertNull(alumno);
    }

    @Test
    void testAlumnoEntityConstructor() {
        // Given
        Long id = 1L;
        String rut = "12345678-9";
        String nombre = "Juan";
        String apellido = "Pérez";

        // When
        AlumnoEntity entity = new AlumnoEntity(id, rut, nombre, apellido);

        // Then
        assertNotNull(entity);
        assertEquals(id, entity.getId());
        assertEquals(rut, entity.getRut());
        assertEquals(nombre, entity.getNombre());
        assertEquals(apellido, entity.getApellido());
    }

    @Test
    void testAlumnoEntitySetters() {
        // Given
        AlumnoEntity entity = new AlumnoEntity();

        // When
        entity.setId(1L);
        entity.setRut("12345678-9");
        entity.setNombre("Juan");
        entity.setApellido("Pérez");

        // Then
        assertEquals(1L, entity.getId());
        assertEquals("12345678-9", entity.getRut());
        assertEquals("Juan", entity.getNombre());
        assertEquals("Pérez", entity.getApellido());
    }
}
