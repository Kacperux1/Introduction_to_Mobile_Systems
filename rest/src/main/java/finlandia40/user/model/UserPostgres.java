package finlandia40.user.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@NoArgsConstructor
@Entity
public class UserPostgres {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String login;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, unique = true)
    @Setter
    private String email;

    @Column
    @Setter
    private String number;

    @Column
    @Setter
    private String country;

    @Column
    @Setter
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
