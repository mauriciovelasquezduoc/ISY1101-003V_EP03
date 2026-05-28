package cl.duocuc.fechaapi.application.controller;

import cl.duocuc.fechaapi.domain.Alumno;
import cl.duocuc.fechaapi.domain.AlumnoService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AlumnoController.class)
class AlumnoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AlumnoService alumnoService;

    @Autowired
    private ObjectMapper objectMapper;

    private Alumno alumno1;
    private Alumno alumno2;

    @BeforeEach
    void setUp() {
        alumno1 = new Alumno("12345678-9", "Juan", "Pérez");
        alumno1.setId(1L);
        alumno2 = new Alumno("23456789-0", "María", "González");
        alumno2.setId(2L);
    }

    @Test
    void testGetAllAlumnos() throws Exception {
        // Given
        when(alumnoService.getAllAlumnos()).thenReturn(List.of(alumno1, alumno2));

        // When & Then
        mockMvc.perform(get("/api/alumnos"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[0].rut").value("12345678-9"))
            .andExpect(jsonPath("$[1].nombre").value("María"));

        verify(alumnoService, times(1)).getAllAlumnos();
    }

    @Test
    void testGetAlumnoByIdFound() throws Exception {
        // Given
        when(alumnoService.getAlumnoById(1L)).thenReturn(java.util.Optional.of(alumno1));

        // When & Then
        mockMvc.perform(get("/api/alumnos/{id}", 1L))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.rut").value("12345678-9"))
            .andExpect(jsonPath("$.nombre").value("Juan"));

        verify(alumnoService, times(1)).getAlumnoById(1L);
    }

    @Test
    void testGetAlumnoByIdNotFound() throws Exception {
        // Given
        when(alumnoService.getAlumnoById(99L)).thenReturn(java.util.Optional.empty());

        // When & Then
        mockMvc.perform(get("/api/alumnos/{id}", 99L))
            .andExpect(status().isNotFound());

        verify(alumnoService, times(1)).getAlumnoById(99L);
    }

    @Test
    void testGetAlumnoByRutFound() throws Exception {
        // Given
        when(alumnoService.getAlumnoByRut("12345678-9")).thenReturn(java.util.Optional.of(alumno1));

        // When & Then
        mockMvc.perform(get("/api/alumnos/rut/{rut}", "12345678-9"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.rut").value("12345678-9"));

        verify(alumnoService, times(1)).getAlumnoByRut("12345678-9");
    }

    @Test
    void testCreateAlumno() throws Exception {
        // Given
        when(alumnoService.createAlumno(any(Alumno.class))).thenReturn(alumno1);

        // When & Then
        mockMvc.perform(post("/api/alumnos")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(alumno1)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.rut").value("12345678-9"));

        verify(alumnoService, times(1)).createAlumno(any(Alumno.class));
    }

    @Test
    void testUpdateAlumno() throws Exception {
        // Given
        Alumno alumnoActualizado = new Alumno("12345678-9", "Juan", "Rodríguez");
        alumnoActualizado.setId(1L);
        when(alumnoService.updateAlumno(eq(1L), any(Alumno.class))).thenReturn(alumnoActualizado);

        // When & Then
        mockMvc.perform(put("/api/alumnos/{id}", 1L)
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(alumnoActualizado)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.apellido").value("Rodríguez"));

        verify(alumnoService, times(1)).updateAlumno(eq(1L), any(Alumno.class));
    }

    @Test
    void testDeleteAlumno() throws Exception {
        // Given
        when(alumnoService.getAlumnoById(1L)).thenReturn(java.util.Optional.of(alumno1));

        // When & Then
        mockMvc.perform(delete("/api/alumnos/{id}", 1L))
            .andExpect(status().isNoContent());

        verify(alumnoService, times(1)).deleteAlumno(1L);
    }

    @Test
    void testUpdateAlumnoNotFound() throws Exception {
        // Given
        when(alumnoService.updateAlumno(eq(99L), any(Alumno.class))).thenReturn(null);

        // When & Then
        mockMvc.perform(put("/api/alumnos/{id}", 99L)
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(alumno1)))
            .andExpect(status().isNotFound());

        verify(alumnoService, times(1)).updateAlumno(eq(99L), any(Alumno.class));
    }

    @Test
    void testDeleteAlumnoNotFound() throws Exception {
        // Given
        when(alumnoService.getAlumnoById(99L)).thenReturn(java.util.Optional.empty());

        // When & Then
        mockMvc.perform(delete("/api/alumnos/{id}", 99L))
            .andExpect(status().isNotFound());

        verify(alumnoService, never()).deleteAlumno(any(Long.class));
    }
}
