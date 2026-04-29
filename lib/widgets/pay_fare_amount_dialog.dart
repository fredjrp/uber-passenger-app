import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uber_user/l10n/app_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../global/global.dart';

class PayFareAmountDialog extends StatefulWidget {
  final double? price;

  const PayFareAmountDialog({super.key, this.price});

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  
  Future<void> initPayment({required String email, required double amount, required BuildContext context}) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(
        Uri.parse('https://us-central1-uber-clone-fab67.cloudfunctions.net/stripePaymentIntentRequest'),
        body: {
          'email': email,
          'amount': (amount * 100).toInt().toString(), // Convert to cents
        },
      );

      final jsonResponse = jsonDecode(response.body);
      log(jsonResponse.toString());

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['paymentIntent'],
          merchantDisplayName: 'Uber Passenger App',
          customerId: jsonResponse['customer'],
          customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US', testEnv: true),
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.green,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment is successful')),
      );
      Navigator.pop(context, "cashPayed"); // Assuming success logic
    } catch (e) {
      if (!mounted) return;
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.error.localizedMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.price.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              "\$${widget.price}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 50),
            ),
            const SizedBox(height: 20),
            Text(
              localizations.thisIsTheTotalTripFareAmountPleasePayToDriver,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            // Pay with Card
            ElevatedButton(
              onPressed: () => initPayment(
                amount: widget.price ?? 0,
                context: context,
                email: userModelCurrentInfo?.email ?? "test@example.com",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pay with Card", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("\$${widget.price}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 15),

            // Pay Cash
            ElevatedButton(
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted) Navigator.pop(context, "cashPayed");
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pay Cash", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("\$${widget.price}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
