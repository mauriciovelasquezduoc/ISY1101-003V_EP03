package cl.duocuc.fechaapi.config;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.forwardedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(RedocController.class)
class HomePageTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldServeProfessionalHomePageAtRoot() throws Exception {
        mockMvc.perform(get("/"))
            .andExpect(status().isOk())
            .andExpect(forwardedUrl("index.html"));

        mockMvc.perform(get("/index.html"))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("Gestion profesional de alumnos")))
            .andExpect(content().string(containsString("href=\"/swagger-ui.html\"")))
            .andExpect(content().string(containsString("href=\"/redoc.html\"")))
            .andExpect(content().string(containsString("href=\"/api-docs\"")))
            .andExpect(content().string(containsString("href=\"/api/alumnos\"")));
    }
}
