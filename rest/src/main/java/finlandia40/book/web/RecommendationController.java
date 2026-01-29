package finlandia40.book.web;

import finlandia40.book.business.BookService;
import finlandia40.book.external.GroqModels;
import finlandia40.book.external.GroqService;
import finlandia40.book.model.Book;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/external")
public class RecommendationController {

    private final GroqService groqService;
    private final BookService bookService;

    public RecommendationController(GroqService groqService, BookService bookService) {
        this.groqService = groqService;
        this.bookService = bookService;
    }

    @PostMapping("/chat")
    public String chatWithAi(@RequestBody List<GroqModels.Message> history) {
        List<Book> availableOffers = bookService.getAllBooks(null);
        return groqService.chatWithAi(history, availableOffers);
    }
}
