package com.decipher.payment;

import com.stripe.exception.StripeException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    @Autowired
    private StripeService stripeService;

    @PostMapping("/subscribe")
    public String createSubscription(@RequestBody Map<String, String> data) throws StripeException {
        String email = data.get("email");
        String name = data.get("name");
        String priceId = data.get("priceId"); // Stripe Price ID (e.g., price_H5ggv...)

        String customerId = stripeService.createCustomer(email, name);
        return stripeService.createSubscription(customerId, priceId);
    }
}
