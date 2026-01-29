package finlandia40.chat.websocket;

import finlandia40.chat.business.ChatService;
import finlandia40.chat.dto.DtoMapper;
import finlandia40.chat.dto.MessageDto;
import finlandia40.chat.model.ChatMessage;
import finlandia40.user.business.UserService;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
public class WebSocketController {

    private final ChatService chatService;
    private final UserService userService;
    private final DtoMapper dtoMapper;
    private final SimpMessagingTemplate simpMessagingTemplate;

    public WebSocketController(ChatService chatService, UserService userService, DtoMapper dtoMapper, SimpMessagingTemplate simpMessagingTemplate) {
        this.chatService = chatService;
        this.userService = userService;
        this.dtoMapper = dtoMapper;
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    @MessageMapping("/chat-socket")
    public void sendMessage(MessageDto dto, Principal principal) {
        if (principal == null) {
            return;
        }

        ChatMessage message = chatService.saveMessage(dto, principal.getName());
        MessageDto responseDto = dtoMapper.convertChatMessageEntityToChatMessageDto(message);

        simpMessagingTemplate.convertAndSend(
                "/topic/messages/" + dto.receiverId(), responseDto
        );

        simpMessagingTemplate.convertAndSend(
                "/topic/messages/" + userService.loadUserByLogin(principal.getName()).getId(), responseDto
        );
    }
}
