package finlandia40.book.data;

import finlandia40.book.model.CompletedOffer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CompletedOfferRepository extends JpaRepository<CompletedOffer, Long> {
    List<CompletedOffer> findAllByBuyerLogin(String login);
    List<CompletedOffer> findAllBySellerLogin(String login);
}
