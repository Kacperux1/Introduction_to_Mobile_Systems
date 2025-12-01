package finlandia40.user.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@Entity
public class UserPostgres {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String login;

    @Column(length = 100, nullable = false)
    private String password;

    @Column(nullable = false, unique = true)
    private String email;

    @Column
    private String number;

    @Column
    private String country;

    @Column
    private String city;

    public UserPostgres(String login, String password, String email, String number, String country, String city) {
        this.login = login;
        this.password = password;
        this.email = email;
        this.number = number;
        this.country = country;
        this.city = city;
    }
}
