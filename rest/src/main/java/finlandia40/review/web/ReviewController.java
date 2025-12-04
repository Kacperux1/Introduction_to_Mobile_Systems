package finlandia40.review.web;

import finlandia40.review.business.ReviewService;
import finlandia40.review.model.Review;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Review createReview(@RequestBody CreateReviewRequest request, Principal principal) {
        return reviewService.createReview(request, principal.getName());
    }

    @GetMapping
    public List<Review> getReviews(@RequestParam Long bookId) {
        return reviewService.getReviewsForBook(bookId);
    }

    public record CreateReviewRequest(Long bookId, int rating, String comment) {}
}
