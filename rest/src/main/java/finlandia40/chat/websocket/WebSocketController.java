package finlandia40.chat.websocket;

import finlandia40.chat.business.ChatService;
import finlandia40.chat.dto.MessageDto;
import finlandia40.chat.model.ChatMessage;
import finlandia40.user.business.UserService;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.security.Principal;
import java.time.LocalDateTime;

@Controller
public class WebSocketController {

    private final ChatService chatService;
    private final UserService userService;

    private final SimpMessagingTemplate simpMessagingTemplate;

    public WebSocketController(ChatService chatService, UserService userService, SimpMessagingTemplate simpMessagingTemplate) {
        this.chatService = chatService;
        this.userService = userService;
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    @MessageMapping("/chat-socket")
    public void sendMessage(MessageDto dto, Principal principal) {

        ChatMessage message = chatService.saveMessage(dto);


        simpMessagingTemplate.convertAndSend(
                "/topic/messages/" + dto.receiverId(), message
        );

        simpMessagingTemplate.convertAndSend(
                "/topic/messages/" + userService.loadUserByLogin(principal.getName()).getId(), message
        );
    }


}
