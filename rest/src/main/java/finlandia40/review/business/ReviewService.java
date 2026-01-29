package finlandia40.review.business;

import finlandia40.book.data.OfferRepository;
import finlandia40.book.model.Offer;
import finlandia40.review.data.ReviewRepository;
import finlandia40.review.model.Review;
import finlandia40.review.web.ReviewController;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final OfferRepository offerRepository;

    public ReviewService(ReviewRepository reviewRepository, OfferRepository offerRepository) {
        this.reviewRepository = reviewRepository;
        this.offerRepository = offerRepository;
    }

    @Transactional
    public Review createReview(ReviewController.CreateReviewRequest request, String reviewerName) {
        Offer offer = offerRepository.findById(request.bookId())
                .orElseThrow(() -> new RuntimeException("Offer not found with id: " + request.bookId()));

        Review review = new Review(
                request.rating(),
                request.comment(),
                reviewerName,
                offer
        );

        offer.getReviews().add(review);

        return reviewRepository.save(review);
    }

    @Transactional(readOnly = true)
    public List<Review> getReviewsForOffer(Long offerId) {
        if (!offerRepository.existsById(offerId)) {
            throw new RuntimeException("Offer not found with id: " + offerId);
        }
        return reviewRepository.findAllByOfferId(offerId);
    }
}
