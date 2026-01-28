package finlandia40.chat.dto;


import finlandia40.chat.model.ChatMessage;
import org.springframework.stereotype.Component;

@Component
public class DtoMapper {



    public MessageDto convertChatMessageEntityToChatMessageDto
            (ChatMessage chatMessage) {
        return MessageDto.builder()
                .receiverId(chatMessage.getSecondUser().getId())
                .content(chatMessage.getMessage())
                .sent(chatMessage.getSent())
                .build();
    }
}
