package finlandia40.user.business;

import finlandia40.user.data.UserRepository;
import finlandia40.user.model.UserPostgres;
import finlandia40.user.web.UserController;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {
        UserPostgres user = userRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with login: " + login));

        return User.builder()
                .username(user.getLogin())
                .password(user.getPassword())
                .authorities(new ArrayList<>())
                .build();
    }

    public void createUser(String login, String password, String email, String number, String country, String city) {
        UserPostgres user = new UserPostgres(login, password, email, number, country, city);
        userRepository.save(user);
    }

    public UserPostgres loadUserByLogin(String login) {
        return userRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with login: " + login));
    }

    public UserPostgres loadUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with id: " + id));
    }

    @Transactional
    public void updateUser(String login, UserController.UpdateProfileRequest request) {
        UserPostgres user = loadUserByLogin(login);
        user.setEmail(request.email());
        user.setNumber(request.number());
        user.setCountry(request.country());
        user.setCity(request.city());
        userRepository.save(user);
    }
}
