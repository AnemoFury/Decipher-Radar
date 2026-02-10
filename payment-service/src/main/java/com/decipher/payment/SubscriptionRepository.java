package com.decipher.payment;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<SubscriptionEntity, Long> {
    Optional<SubscriptionEntity> findByStripeSubscriptionId(String stripeSubscriptionId);

    Optional<SubscriptionEntity> findByUserId(String userId);
}
