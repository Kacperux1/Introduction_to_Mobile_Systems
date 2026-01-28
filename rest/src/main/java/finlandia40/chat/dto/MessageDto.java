package finlandia40.chat.dto;


import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record MessageDto(
        @NotNull
        Long receiverId,
        @Min(1)
        String content,
        @NotNull
        LocalDateTime sent
) {
}
