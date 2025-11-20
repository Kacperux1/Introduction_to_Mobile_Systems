package finlandia40.user.web;

import finlandia40.user.business.UserService;
import finlandia40.user.model.UserPostgres;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequestMapping("/user")
class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }


    @GetMapping("/profile")
    public UserProfileResponse getProfile(Authentication authentication) {
        String login = authentication.getName();

        UserPostgres user = userService.loadUserByLogin(login);

        return new UserProfileResponse(user.getLogin());
    }

    public record UserProfileResponse(String login) {}
}
