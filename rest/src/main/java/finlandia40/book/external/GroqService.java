package finlandia40.book.external;

import finlandia40.book.model.Book;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GroqService {

    private final RestTemplate restTemplate;

    @Value("${groq.api.key:your_groq_api_key_here}")
    private String apiKey;

    private static final String GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
    private static final String MODEL = "openai/gpt-oss-120b";

    public GroqService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public String chatWithAi(List<GroqModels.Message> history, List<Book> availableBooks) {
        String inventoryContext = availableBooks.stream()
                .map(b -> String.format("- \"%s\" by %s (ID: %d, Price: %.2f)", b.getTitle(), b.getAuthor(), b.getId(), b.getPrice()))
                .collect(Collectors.joining("\n"));

        String systemPrompt = "You are 'BookScout AI', a friendly librarian for the 'BookTrade' app. " +
                "1. Interview the user to find their perfect book. " +
                "2. If you recommend a book from the 'Local Inventory' below, ALWAYS include its ID in this format: [BUY:ID]. " +
                "3. Local Inventory:\n" + inventoryContext + "\n" +
                "4. If you recommend a book NOT in the inventory, suggest searching for it in the Open Library. " +
                "5. Keep it natural and helpful. Ask one question at a time to keep the interview going." +
                "6. Always respond in natural language (don't use markdown and asterisk symbols).";

        List<GroqModels.Message> messages = new ArrayList<>();
        messages.add(new GroqModels.Message("system", systemPrompt));
        messages.addAll(history);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        GroqModels.ChatRequest request = new GroqModels.ChatRequest(
                MODEL,
                messages,
                0.7
        );

        HttpEntity<GroqModels.ChatRequest> entity = new HttpEntity<>(request, headers);

        try {
            GroqModels.ChatResponse response = restTemplate.postForObject(GROQ_API_URL, entity, GroqModels.ChatResponse.class);
            if (response != null && !response.choices().isEmpty()) {
                return response.choices().get(0).message().content();
            }
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }

        return "I'm sorry, I couldn't process that request.";
    }

    // Deprecated or kept for simple recommendations
    public String getRecommendations(List<String> likedBooks) {
        String prompt = "Recommend 5 books similar to: " + String.join(", ", likedBooks);
        return chatWithAi(List.of(new GroqModels.Message("user", prompt)), List.of());
    }
}
