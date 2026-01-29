package finlandia40.book.model;

import finlandia40.user.model.UserPostgres;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class CompletedOffer extends Offer {

    @Column(nullable = false)
    private LocalDateTime completionDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false)
    private UserPostgres buyer;

    public CompletedOffer(String title, String author, String bookCondition, Double price, String imageUrl, UserPostgres seller, UserPostgres buyer, LocalDateTime completionDate) {
        super(title, author, bookCondition, price, imageUrl, seller);
        this.buyer = buyer;
        this.completionDate = completionDate;
    }

    public static CompletedOffer fromBook(Book book, UserPostgres buyer) {
        return new CompletedOffer(
                book.getTitle(),
                book.getAuthor(),
                book.getBookCondition(),
                book.getPrice(),
                book.getImageUrl(),
                book.getSeller(),
                buyer,
                LocalDateTime.now()
        );
    }
}
