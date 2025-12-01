package finlandia40.user.business;

import finlandia40.user.data.UserRepository;
import finlandia40.user.model.UserPostgres;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

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
}
