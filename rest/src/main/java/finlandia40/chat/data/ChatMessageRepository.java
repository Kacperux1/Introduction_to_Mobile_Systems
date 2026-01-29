package finlandia40.chat.data;

import finlandia40.chat.model.ChatMessage;
import finlandia40.user.model.UserPostgres;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    List<ChatMessage> findByFirstUserAndSecondUserOrFirstUserAndSecondUser(
            UserPostgres firstUser1, UserPostgres secondUser1,
            UserPostgres firstUser2, UserPostgres secondUser2);

    List<ChatMessage> findAllByFirstUser(UserPostgres firstUser);
    List<ChatMessage> findAllBySecondUser(UserPostgres secondUser);

}
