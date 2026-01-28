package finlandia40.chat.model;


import finlandia40.user.model.UserPostgres;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //pierwszy user-nadawca, drugi-odbiorca
    @ManyToOne
    @JoinColumn(name = "first_user", nullable = false)
    private UserPostgres firstUser;

    @ManyToOne
    @JoinColumn(name = "second_user", nullable = false)
    private UserPostgres secondUser;

    @Column
    private LocalDateTime sent;

    @Column
    private String message;

}
