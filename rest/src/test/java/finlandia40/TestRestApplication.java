package finlandia40;

import org.springframework.boot.SpringApplication;

public class TestRestApplication {

    public static void main(String[] args) {
        SpringApplication.from(RestApplication::main).with(TestcontainersConfiguration.class).run(args);
    }

}
