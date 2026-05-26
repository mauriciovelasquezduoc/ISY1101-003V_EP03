package cl.duocuc.fechaapi.config;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RedocController {

    @GetMapping({"/redoc", "/redoc.html"})
    public String redoc() {
        return "redirect:/redoc/index.html";
    }
}
