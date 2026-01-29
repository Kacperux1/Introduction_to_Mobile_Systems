package finlandia40.book.web;

import finlandia40.book.business.BookService;
import finlandia40.book.model.Book;
import finlandia40.review.model.Review;
import finlandia40.user.model.UserPostgres;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping("/books")
    public List<BookResponse> getAllBooks(@RequestParam(required = false) String title) {
        return bookService.getAllBooks(title).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    @GetMapping("/books/{id}")
    public BookResponse getBookById(@PathVariable Long id) {
        Book book = bookService.getBookById(id);
        return convertToResponse(book);
    }

    @PostMapping("/books")
    @ResponseStatus(HttpStatus.CREATED)
    public BookResponse createBook(@RequestBody CreateBookRequest request, Principal principal) {
        Book newBook = bookService.createBook(request, principal.getName());
        return convertToResponse(newBook);
    }

    @PatchMapping("/books/{id}/image")
    public void updateBookImage(@PathVariable Long id, @RequestBody UpdateImageRequest request) {
        bookService.updateBookImage(id, request.imageUrl());
    }

    private BookResponse convertToResponse(Book book) {
        List<ReviewResponse> reviewResponses = book.getReviews().stream()
                .map(this::convertReviewToResponse)
                .collect(Collectors.toList());

        UserPostgres seller = book.getSeller();

        return new BookResponse(
                book.getId(),
                book.getTitle(),
                book.getAuthor(),
                book.getBookCondition(),
                book.getPrice(),
                book.getImageUrl(),
                seller != null ? seller.getLogin() : null,
                seller != null ? seller.getEmail() : null,
                reviewResponses
        );
    }

    private ReviewResponse convertReviewToResponse(Review review) {
        return new ReviewResponse(review.getId(), review.getRating(), review.getComment(), review.getReviewerName());
    }

    // DTOs
    public record CreateBookRequest(String title, String author, String condition, Double price, String imageUrl) {}
    public record UpdateImageRequest(String imageUrl) {}
    public record ReviewResponse(Long id, int rating, String comment, String reviewerName) {}
    public record BookResponse(Long id, String title, String author, String condition, Double price, String imageUrl, String sellerLogin, String sellerEmail, List<ReviewResponse> reviews) {}
}
