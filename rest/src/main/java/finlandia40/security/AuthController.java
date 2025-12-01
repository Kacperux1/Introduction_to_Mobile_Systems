package finlandia40.security;

import finlandia40.user.business.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    public AuthController(AuthenticationManager authenticationManager, JwtService jwtService, UserService userService, PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/login")
    public TokenResponse login(@RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.login(),
                        request.password()
                )
        );
        String token = jwtService.generateToken(request.login());
        return new TokenResponse(token);
    }

    @PostMapping("/register")
    public TokenResponse register(@RequestBody RegisterRequest request) {
        try {
            userService.loadUserByUsername(request.login());
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User with this login already exists");
        } catch (UsernameNotFoundException e) {

        }

        userService.createUser(
                request.login(),
                passwordEncoder.encode(request.password()),
                request.email(),
                request.number(),
                request.country(),
                request.city()
        );

        String token = jwtService.generateToken(request.login());
        return new TokenResponse(token);
    }

    public record RegisterRequest(String login, String password, String email, String number, String country, String city) {}
    public record TokenResponse(String token) {}
    public record LoginRequest(String login, String password) {}
}
