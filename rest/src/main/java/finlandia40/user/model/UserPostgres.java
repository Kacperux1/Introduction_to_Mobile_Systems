package finlandia40.user.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;


@Getter
@NoArgsConstructor
@Entity
public class UserPostgres {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column( nullable = false, unique = true )
    private String login;

    @Column(length = 60, nullable = false)
    private String password;

    public UserPostgres(String login, String password) {
        this.login = login;
        this.password = password;
    }
}
