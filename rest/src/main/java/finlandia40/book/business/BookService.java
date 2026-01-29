package finlandia40.book.business;

import finlandia40.book.data.BookRepository;
import finlandia40.book.model.Book;
import finlandia40.book.web.BookController;
import finlandia40.user.business.UserService;
import finlandia40.user.model.UserPostgres;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class BookService {

    private final BookRepository bookRepository;
    private final UserService userService;

    public BookService(BookRepository bookRepository, UserService userService) {
        this.bookRepository = bookRepository;
        this.userService = userService;
    }

    public List<Book> getAllBooks(String title) {
        if (title == null || title.isEmpty()) {
            return bookRepository.findAll();
        }
        return bookRepository.findByTitleContainingIgnoreCase(title);
    }

    public Book getBookById(Long id) {
        return bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Book not found with id: " + id));
    }

    public Book createBook(BookController.CreateBookRequest request, String sellerLogin) {
        UserPostgres seller = userService.loadUserByLogin(sellerLogin);
        Book book = new Book(
                request.title(),
                request.author(),
                request.condition(),
                request.price(),
                request.imageUrl(),
                seller
        );
        return bookRepository.save(book);
    }

    @Transactional
    public void updateBookImage(Long id, String imageUrl) {
        Book book = getBookById(id);
        if (book.getImageUrl() == null || book.getImageUrl().isEmpty()) {
            book.setImageUrl(imageUrl);
            bookRepository.save(book);
        }
    }
}
