package cl.duocuc.fechaapi.config;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class RedocControllerTest {

    @Test
    void testRedocRedirect() {
        RedocController controller = new RedocController();

        String view = controller.redoc();

        assertEquals("redirect:/redoc/index.html", view);
    }
}
