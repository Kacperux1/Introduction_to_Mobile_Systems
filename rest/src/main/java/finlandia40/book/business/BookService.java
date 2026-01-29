package finlandia40.book.business;

import finlandia40.book.data.BookRepository;
import finlandia40.book.data.CompletedOfferRepository;
import finlandia40.book.model.Book;
import finlandia40.book.model.CompletedOffer;
import finlandia40.book.web.BookController;
import finlandia40.user.business.UserService;
import finlandia40.user.model.UserPostgres;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class BookService {

    private final BookRepository bookRepository;
    private final CompletedOfferRepository completedOfferRepository;
    private final UserService userService;

    public BookService(BookRepository bookRepository, CompletedOfferRepository completedOfferRepository, UserService userService) {
        this.bookRepository = bookRepository;
        this.completedOfferRepository = completedOfferRepository;
        this.userService = userService;
    }

    public List<Book> getAllBooks(String title) {
        if (title == null || title.isEmpty()) {
            return bookRepository.findAllAvailable();
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

    @Transactional
    public Book buyBook(Long bookId, String buyerLogin) {
        Book book = getBookById(bookId);
        UserPostgres buyer = userService.loadUserByLogin(buyerLogin);

        if (book.getSeller().getLogin().equals(buyerLogin)) {
            throw new RuntimeException("You cannot buy your own book");
        }
        
        if (book.isSold() || book.getPendingBuyer() != null) {
            throw new RuntimeException("Book is already sold or has a pending buyer");
        }

        book.setPendingBuyer(buyer);
        return bookRepository.save(book);
    }

    @Transactional
    public CompletedOffer confirmSale(Long bookId, String sellerLogin) {
        Book book = getBookById(bookId);
        
        if (!book.getSeller().getLogin().equals(sellerLogin)) {
            throw new RuntimeException("Only the seller can confirm the sale");
        }
        
        if (book.getPendingBuyer() == null) {
            throw new RuntimeException("No pending buyer for this book");
        }

        CompletedOffer completedOffer = CompletedOffer.fromBook(book, book.getPendingBuyer());
        
        bookRepository.delete(book);
        return completedOfferRepository.save(completedOffer);
    }

    public List<Book> getPendingSales(String sellerLogin) {
        return bookRepository.findPendingSales(sellerLogin);
    }

    public List<CompletedOffer> getPurchaseHistory(String login) {
        return completedOfferRepository.findAllByBuyerLogin(login);
    }

    public List<CompletedOffer> getSalesHistory(String login) {
        return completedOfferRepository.findAllBySellerLogin(login);
    }
}
