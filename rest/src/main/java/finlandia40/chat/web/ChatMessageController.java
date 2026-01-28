package finlandia40.chat.web;

import finlandia40.chat.business.ChatService;
import finlandia40.chat.dto.DtoMapper;
import finlandia40.chat.dto.MessageDto;
import finlandia40.chat.model.ChatMessage;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class ChatMessageController {

    private final ChatService chatService;

    private final DtoMapper dtoMapper;

    public ChatMessageController(ChatService chatService, DtoMapper dtoMapper) {
        this.chatService = chatService;
        this.dtoMapper = dtoMapper;
    }


    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<MessageDto> getChatMessagesForTwoGivenUsers
            (@RequestParam @Valid Long secondUserId) {
        return chatService.getMessagesForTwoCertainUsers(secondUserId).stream()
                .map(dtoMapper::convertChatMessageEntityToChatMessageDto).toList();
    }
}
