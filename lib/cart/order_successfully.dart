import 'package:flutter/material.dart';
import 'package:smm_power/navigation_source.dart';

class OrderSuccessfully extends StatefulWidget {
  final NavigationSource source;

  const OrderSuccessfully({
    super.key,
    required this.source,
  });

  @override
  State<OrderSuccessfully> createState() => _OrderSuccessfullyState();
}

class _OrderSuccessfullyState extends State<OrderSuccessfully> {
  @override
  void initState() {
    super.initState();
    _redirectAfterDelay();
  }

  void _redirectAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      int count = 0;
      int popCount;

      if (widget.source == NavigationSource.bottomNav) {
        // Stack: CartTab → OrderSummary → Payment → OrderSuccessfully
        // Pop 3 to go back to Cart tab
        popCount = 3;
      } else if (widget.source == NavigationSource.addCart) {
        // Stack: ProductDetail → Cart → OrderSummary → Payment → OrderSuccessfully
        // Pop 4 to go back to ProductDetail
        popCount = 4;
      } else {
        // buyNow
        // Stack: ProductDetail → OrderSummary → Payment → OrderSuccessfully
        // Pop 3 to go back to ProductDetail
        popCount = 3;
      }

      Navigator.of(context).popUntil((_) => count++ >= popCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/cart/success.gif',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ordered Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}