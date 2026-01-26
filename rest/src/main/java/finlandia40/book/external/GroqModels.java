package finlandia40.book.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

public class GroqModels {

    public record ChatRequest(String model, List<Message> messages, double temperature) {}

    public record Message(String role, String content) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ChatResponse(List<Choice> choices) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Choice(Message message) {}
}
