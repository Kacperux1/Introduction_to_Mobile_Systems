package finlandia40.book.model;

import finlandia40.user.model.UserPostgres;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Book extends Offer {

    @Column(nullable = false)
    private boolean isSold = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pending_buyer_id")
    private UserPostgres pendingBuyer;

    public Book(String title, String author, String bookCondition, Double price, String imageUrl, UserPostgres seller) {
        super(title, author, bookCondition, price, imageUrl, seller);
    }
}
