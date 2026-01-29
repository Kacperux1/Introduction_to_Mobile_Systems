package finlandia40.chat.business;

import finlandia40.chat.data.ChatMessageRepository;
import finlandia40.chat.dto.MessageDto;
import finlandia40.chat.model.ChatMessage;
import finlandia40.user.business.UserService;
import finlandia40.user.model.UserPostgres;
import finlandia40.user.web.UserController;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

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

    public ChatMessage saveMessage(MessageDto dto, String senderLogin) {
        UserPostgres sender = userService.loadUserByLogin(senderLogin);
        UserPostgres receiver = userService.loadUserById(dto.receiverId());
        ChatMessage chatMessage = ChatMessage.builder()
                .firstUser(sender)
                .secondUser(receiver)
                .message(dto.content())
                .sent(LocalDateTime.now())
                .build();
        return chatMessageRepository.save(chatMessage);
    }

    public List<UserController.UserProfileResponse> getActiveChatPartners() {
        UserDetails currentUserDetails =
                (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        UserPostgres currentUser = userService.loadUserByLogin(currentUserDetails.getUsername());

        List<ChatMessage> sentMessages = chatMessageRepository.findAllByFirstUser(currentUser);
        List<ChatMessage> receivedMessages = chatMessageRepository.findAllBySecondUser(currentUser);

        return Stream.concat(
                sentMessages.stream().map(ChatMessage::getSecondUser),
                receivedMessages.stream().map(ChatMessage::getFirstUser)
        )
        .distinct()
        .map(u -> new UserController.UserProfileResponse(u.getId(), u.getLogin(), u.getEmail(), u.getNumber(), u.getCountry(), u.getCity()))
        .collect(Collectors.toList());
    }
}
