package finlandia40.book.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import finlandia40.review.model.Review;
import finlandia40.user.model.UserPostgres;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class Offer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String author;

    @Column(name = "book_condition", nullable = false)
    private String bookCondition;

    @Column(nullable = false)
    private Double price;

    @Column(name = "image_url")
    private String imageUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id")
    private UserPostgres seller;

    @OneToMany(mappedBy = "offer", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private List<Review> reviews = new ArrayList<>();

    public Offer(String title, String author, String bookCondition, Double price, String imageUrl, UserPostgres seller) {
        this.title = title;
        this.author = author;
        this.bookCondition = bookCondition;
        this.price = price;
        this.imageUrl = imageUrl;
        this.seller = seller;
    }
}
