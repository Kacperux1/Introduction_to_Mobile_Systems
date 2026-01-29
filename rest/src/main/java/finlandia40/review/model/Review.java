package finlandia40.review.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import finlandia40.book.model.Offer;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private int rating;

    @Column(nullable = false, length = 1000)
    private String comment;

    @Column(nullable = false)
    private String reviewerName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "offer_id", nullable = false)
    @JsonBackReference
    private Offer offer;

    public Review(int rating, String comment, String reviewerName, Offer offer) {
        this.rating = rating;
        this.comment = comment;
        this.reviewerName = reviewerName;
        this.offer = offer;
    }
}
