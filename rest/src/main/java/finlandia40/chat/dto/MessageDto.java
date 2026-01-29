package finlandia40.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import java.time.LocalDateTime;

@Builder
public record MessageDto(
        Long senderId,
        @NotNull
        Long receiverId,
        @NotBlank
        String content,
        LocalDateTime sent
) {
}
