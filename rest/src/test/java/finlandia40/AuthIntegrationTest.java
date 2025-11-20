package finlandia40;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AuthIntegrationTest {

    @LocalServerPort
    private int port;

    @BeforeEach
    void setup() {
        RestAssured.port = port;
        RestAssured.baseURI = "http://localhost";
    }


    @Test
    void registerLoginAndAccessProtectedEndpoint() {
        // 1️⃣ Rejestracja
        String registerToken = RestAssured.given()
                .contentType(ContentType.JSON)
                .body("{ \"login\": \"testuser\", \"password\": \"1234\" }")
                .log().all() // loguje request
                .when()
                .post("/auth/register")
                .then()
                .log().all() // loguje response
                .statusCode(200)
                .body("token", notNullValue())
                .extract()
                .path("token");

        String loginToken = RestAssured.given()
                .contentType(ContentType.JSON)
                .body("{ \"login\": \"testuser\", \"password\": \"1234\" }")
                .log().all()
                .when()
                .post("/auth/login")
                .then()
                .log().all()
                .statusCode(200)
                .body("token", notNullValue())
                .extract()
                .path("token");

        RestAssured.given()
                .header("Authorization", "Bearer " + loginToken)
                .log().all()
                .when()
                .get("/user/profile")
                .then()
                .log().all()
                .statusCode(200)
                .body("login", equalTo("testuser"));
    }


    @Test
    void accessProtectedEndpointWithoutTokenShouldFail() {
        RestAssured.given()
                .when()
                .get("/user/profile")
                .then()
                .statusCode(anyOf(equalTo(401), equalTo(403)));
    }
}
