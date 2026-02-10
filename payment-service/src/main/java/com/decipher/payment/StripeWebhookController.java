package com.decipher.payment;

import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.EventDataObjectDeserializer;
import com.stripe.model.Subscription;
import com.stripe.net.Webhook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/webhooks")
public class StripeWebhookController {

    @Autowired
    private SubscriptionRepository subscriptionRepository;

    @Value("${stripe.webhook.secret}")
    private String endpointSecret;

    @PostMapping("/stripe")
    public String handleStripeWebhook(@RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {
        Event event;

        try {
            event = Webhook.constructEvent(payload, sigHeader, endpointSecret);
        } catch (SignatureVerificationException e) {
            // Invalid signature
            return "Error: Invalid signature";
        }

        // Handle the event
        switch (event.getType()) {
            case "customer.subscription.created":
            case "customer.subscription.updated":
                handleSubscriptionUpdate(event);
                break;
            case "customer.subscription.deleted":
                handleSubscriptionDeletion(event);
                break;
            default:
                System.out.println("Unhandled event type: " + event.getType());
        }

        return "Success";
    }

    private void handleSubscriptionUpdate(Event event) {
        EventDataObjectDeserializer dataObjectDeserializer = event.getDataObjectDeserializer();
        if (dataObjectDeserializer.getObject().isPresent()) {
            Subscription subscription = (Subscription) dataObjectDeserializer.getObject().get();

            SubscriptionEntity entity = subscriptionRepository.findByStripeSubscriptionId(subscription.getId())
                    .orElse(new SubscriptionEntity());

            entity.setStripeSubscriptionId(subscription.getId());
            entity.setStripeCustomerId(subscription.getCustomer());
            entity.setStatus(subscription.getStatus());
            // Usually you'd get userId from metadata or previous mapping
            entity.setUserId(subscription.getMetadata().get("userId"));

            subscriptionRepository.save(entity);
            System.out.println(
                    "Syncing subscription: " + subscription.getId() + " - Status: " + subscription.getStatus());
        }
    }

    private void handleSubscriptionDeletion(Event event) {
        EventDataObjectDeserializer dataObjectDeserializer = event.getDataObjectDeserializer();
        if (dataObjectDeserializer.getObject().isPresent()) {
            Subscription subscription = (Subscription) dataObjectDeserializer.getObject().get();

            subscriptionRepository.findByStripeSubscriptionId(subscription.getId()).ifPresent(entity -> {
                entity.setStatus("canceled");
                subscriptionRepository.save(entity);
            });
            System.out.println("Canceled subscription in DB: " + subscription.getId());
        }
    }
}
