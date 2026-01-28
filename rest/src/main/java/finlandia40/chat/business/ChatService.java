package finlandia40.chat.business;

import finlandia40.chat.data.ChatMessageRepository;
import finlandia40.chat.dto.MessageDto;
import finlandia40.chat.model.ChatMessage;
import finlandia40.user.business.UserService;
import finlandia40.user.model.UserPostgres;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChatService {


    private final ChatMessageRepository chatMessageRepository;
    private final UserService userService;

    public ChatService(ChatMessageRepository chatMessageRepository, UserService userService) {
        this.chatMessageRepository = chatMessageRepository;
        this.userService = userService;
    }

    public List<ChatMessage> getMessagesForTwoCertainUsers(Long secondUserId) {
        UserDetails senderDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        UserPostgres user1 = userService.loadUserByLogin(senderDetails.getUsername());
        UserPostgres user2 = userService.loadUserById(secondUserId);
        return chatMessageRepository.
                findByFirstUserAndSecondUserOrFirstUserAndSecondUser(user1, user2, user2, user1);
    }

    public ChatMessage saveMessage(MessageDto dto) {
        UserDetails senderDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        UserPostgres sender = userService.loadUserByLogin(senderDetails.getUsername());
        UserPostgres receiver = userService.loadUserById(dto.receiverId());
        ChatMessage chatMessage = ChatMessage.builder()
                .firstUser(sender)
                .secondUser(receiver)
                .message(dto.content())
                .build();
        return chatMessageRepository.save(chatMessage);
    }





}
