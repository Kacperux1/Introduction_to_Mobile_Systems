package finlandia40.review.business;

import finlandia40.book.data.BookRepository;
import finlandia40.book.model.Book;
import finlandia40.review.data.ReviewRepository;
import finlandia40.review.model.Review;
import finlandia40.review.web.ReviewController;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final BookRepository bookRepository;

    public ReviewService(ReviewRepository reviewRepository, BookRepository bookRepository) {
        this.reviewRepository = reviewRepository;
        this.bookRepository = bookRepository;
    }

    @Transactional
    public Review createReview(ReviewController.CreateReviewRequest request, String reviewerName) {
        Book book = bookRepository.findById(request.bookId())
                .orElseThrow(() -> new RuntimeException("Book not found with id: " + request.bookId()));

        Review review = new Review(
                request.rating(),
                request.comment(),
                reviewerName,
                book
        );

        book.getReviews().add(review);

        return reviewRepository.save(review);
    }

    @Transactional(readOnly = true)
    public List<Review> getReviewsForBook(Long bookId) {
        if (!bookRepository.existsById(bookId)) {
            throw new RuntimeException("Book not found with id: " + bookId);
        }
        return reviewRepository.findAllByBookId(bookId);
    }
}
