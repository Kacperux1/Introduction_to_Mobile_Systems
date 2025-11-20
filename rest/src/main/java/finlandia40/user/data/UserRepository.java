package finlandia40.user.data;

import finlandia40.user.model.UserPostgres;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserPostgres, Long> {


    Optional<UserPostgres> findByLogin(String login);
}
