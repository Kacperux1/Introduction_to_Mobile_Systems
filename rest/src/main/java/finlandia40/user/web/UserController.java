package finlandia40.user.web;

import finlandia40.user.business.UserService;
import finlandia40.user.model.UserPostgres;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public UserProfileResponse getProfile(Authentication authentication) {
        String login = authentication.getName();
        UserPostgres user = userService.loadUserByLogin(login);
        return new UserProfileResponse(user.getLogin(), user.getEmail(), user.getNumber(), user.getCountry(), user.getCity());
    }

    @PutMapping("/me")
    public ResponseEntity<Void> updateProfile(Authentication authentication, @RequestBody UpdateProfileRequest request) {
        String login = authentication.getName();
        userService.updateUser(login, request);
        return ResponseEntity.ok().build();
    }

    public record UserProfileResponse(String login, String email, String number, String country, String city) {}
    public record UpdateProfileRequest(String email, String number, String country, String city) {}
}
