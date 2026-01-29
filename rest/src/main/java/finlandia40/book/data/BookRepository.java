package finlandia40.book.data;

import finlandia40.book.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {

    @Query("SELECT DISTINCT b FROM Book b LEFT JOIN FETCH b.reviews WHERE b.isSold = false AND b.pendingBuyer IS NULL")
    List<Book> findAllAvailable();

    @Query("SELECT DISTINCT b FROM Book b LEFT JOIN FETCH b.reviews WHERE b.isSold = false AND b.pendingBuyer IS NULL AND lower(b.title) LIKE lower(concat('%', :title, '%'))")
    List<Book> findByTitleContainingIgnoreCase(@Param("title") String title);

    @Override
    @Query("SELECT b FROM Book b LEFT JOIN FETCH b.reviews WHERE b.id = :id")
    Optional<Book> findById(@Param("id") Long id);

    @Query("SELECT b FROM Book b WHERE b.seller.login = :login AND b.pendingBuyer IS NOT NULL AND b.isSold = false")
    List<Book> findPendingSales(@Param("login") String login);
}
