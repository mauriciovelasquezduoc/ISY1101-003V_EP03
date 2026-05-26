package cl.duocuc.fechaapi.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest(classes = SwaggerConfig.class)
class SwaggerConfigTest {

    @Test
    void testCustomOpenAPI() {
        // Given
        SwaggerConfig config = new SwaggerConfig();

        // When
        var openAPI = config.customOpenAPI();

        // Then
        assertNotNull(openAPI);
        assertNotNull(openAPI.getInfo());
        assertEquals("Fecha API", openAPI.getInfo().getTitle());
        assertEquals("1.0.0", openAPI.getInfo().getVersion());
    }
}
