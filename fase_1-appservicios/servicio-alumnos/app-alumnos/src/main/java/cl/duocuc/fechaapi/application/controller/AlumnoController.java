package cl.duocuc.fechaapi.application.controller;

import cl.duocuc.fechaapi.domain.Alumno;
import cl.duocuc.fechaapi.domain.AlumnoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST de Alumno
 * Expone los endpoints CRUD para la entidad Alumno
 */
@RestController
@RequestMapping("/api/alumnos")
@ApiResponses({
    @ApiResponse(responseCode = "400", description = "Solicitud inválida"),
    @ApiResponse(responseCode = "404", description = "Recurso no encontrado"),
    @ApiResponse(responseCode = "500", description = "Error interno del servidor")
})
public class AlumnoController {

    private final AlumnoService alumnoService;

    public AlumnoController(AlumnoService alumnoService) {
        this.alumnoService = alumnoService;
    }

    @GetMapping
    @Operation(summary = "Obtener todos los alumnos", description = "Retorna una lista con todos los alumnos registrados")
    public ResponseEntity<List<Alumno>> getAllAlumnos() {
        List<Alumno> alumnos = alumnoService.getAllAlumnos();
        return ResponseEntity.ok(alumnos);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener alumno por ID", description = "Retorna un alumno específico por su ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Alumno encontrado"),
        @ApiResponse(responseCode = "404", description = "Alumno no encontrado")
    })
    public ResponseEntity<Alumno> getAlumnoById(@PathVariable Long id) {
        return alumnoService.getAlumnoById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/rut/{rut}")
    @Operation(summary = "Obtener alumno por RUT", description = "Retorna un alumno específico por su RUT")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Alumno encontrado"),
        @ApiResponse(responseCode = "404", description = "Alumno no encontrado")
    })
    public ResponseEntity<Alumno> getAlumnoByRut(@PathVariable String rut) {
        return alumnoService.getAlumnoByRut(rut)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @Operation(summary = "Crear nuevo alumno", description = "Crea un nuevo alumno en la base de datos")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Alumno creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos")
    })
    public ResponseEntity<Alumno> createAlumno(@RequestBody Alumno alumno) {
        Alumno nuevo = alumnoService.createAlumno(alumno);
        return ResponseEntity.status(HttpStatus.CREATED).body(nuevo);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar alumno", description = "Actualiza un alumno existente")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Alumno actualizado"),
        @ApiResponse(responseCode = "404", description = "Alumno no encontrado")
    })
    public ResponseEntity<Alumno> updateAlumno(@PathVariable Long id, @RequestBody Alumno alumno) {
        Alumno actualizado = alumnoService.updateAlumno(id, alumno);
        if (actualizado != null) {
            return ResponseEntity.ok(actualizado);
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar alumno", description = "Elimina un alumno por su ID")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Alumno eliminado"),
        @ApiResponse(responseCode = "404", description = "Alumno no encontrado")
    })
    public ResponseEntity<Void> deleteAlumno(@PathVariable Long id) {
        if (alumnoService.getAlumnoById(id).isPresent()) {
            alumnoService.deleteAlumno(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
