import 'package:flutter/material.dart';
import 'package:smm_power/cart/order_successfully.dart';
import 'package:smm_power/navigation_source.dart';

const Color kPrimary = Color(0xFF283897);
const Color kYellow  = Color(0xFFF4E219);
const Color kGreen   = Color(0xFF2E7D32);
const Color kRed     = Color(0xFFD32F2F);

enum PayMethod { upi, card, cod }

class Payment_Category extends StatefulWidget {
  final double totalAmount;
  final NavigationSource source;

  const Payment_Category({
    super.key,
    required this.totalAmount,
    required this.source,
  });

  @override
  State<Payment_Category> createState() => _Payment_CategoryState();
}

class _Payment_CategoryState extends State<Payment_Category> {
  PayMethod? _expanded = PayMethod.upi;
  bool _totalExpanded = false;

  final _cardNumberCtrl = TextEditingController();
  final _validThruCtrl  = TextEditingController();
  final _ccvCtrl        = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _validThruCtrl.dispose();
    _ccvCtrl.dispose();
    super.dispose();
  }

  void _showCodBottomSheet(double sw, double sh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: sh * 0.308, // ~250
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.037, vertical: sh * 0.015),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.012),
                Text(
                  'Confirm Cash on Delivery Order',
                  style: TextStyle(
                    fontSize: sw * 0.043,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: sh * 0.012),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Pay via UPI or Cash\nWhen you receive\nyour order',
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          color: const Color(0xFF1C36CE),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.013),
                    Padding(
                      padding: EdgeInsets.only(top: sh * 0.010),
                      child: Image.asset(
                        'assets/cart/confirm.png',
                        width: sw * 0.480,
                        height: sh * 0.148,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            SizedBox(width: sw * 0.480, height: sh * 0.148),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.002),
                Container(height: 1.5, color: kPrimary),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff999999)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: sh * 0.012),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: const Color(0xff4256D3), fontSize: sw * 0.037, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.027),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderSuccessfully(source: widget.source),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kYellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: sh * 0.012),
                        ),
                        child: Text(
                          'Confirm Order',
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: sw * 0.037),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(sw, sh),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: sh * 0.012),
                _buildStepper(sw, sh),
                SizedBox(height: sh * 0.037),
                _buildTotalBar(sw, sh),
                SizedBox(height: sh * 0.022),
                const Divider(),
                _buildPaySection(
                  method: PayMethod.upi,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'UPI',
                  subtitle: 'Pay by any UPI app',
                  offerText: 'Save upto ₹35 . 16 offers available',
                  child: _buildUpiExpanded(sw, sh),
                  sw: sw,
                  sh: sh,
                ),
                const Divider(),
                SizedBox(height: sh * 0.010),
                _buildPaySection(
                  method: PayMethod.card,
                  icon: Icons.credit_card_outlined,
                  title: 'Credit / Debit / ATM Card',
                  subtitle: 'Add and secure cards as per RBI guidelines',
                  offerText: 'Get upto 5% cashback . 2 offers available',
                  child: _buildCardExpanded(sw, sh),
                  sw: sw,
                  sh: sh,
                ),
                const Divider(),
                SizedBox(height: sh * 0.006),
                _buildPaySection(
                  method: PayMethod.cod,
                  icon: Icons.local_shipping_outlined,
                  title: 'Cash on Delivery',
                  subtitle: '',
                  offerText: null,
                  child: _buildCodExpanded(sw, sh),
                  sw: sw,
                  sh: sh,
                ),
                const Divider(),
                SizedBox(height: sh * 0.049),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(double sw, double sh) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: Icon(Icons.arrow_back_ios_new, size: sw * 0.040, color: Colors.black),
    ),
    titleSpacing: 0,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Step 3 of 3', style: TextStyle(fontSize: sw * 0.027, fontWeight: FontWeight.w400, color: const Color(0xFF555555))),
        SizedBox(height: sh * 0.005),
        Text('Payments', style: TextStyle(color: Colors.black, fontSize: sw * 0.037, fontWeight: FontWeight.w500)),
      ],
    ),
    actions: [
      Container(
        margin: EdgeInsets.only(right: sw * 0.032),
        padding: EdgeInsets.symmetric(horizontal: sw * 0.016, vertical: sh * 0.005),
        decoration: BoxDecoration(color: const Color(0xffEDE4E4), borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: sw * 0.027, color: const Color(0XFF555555)),
            SizedBox(width: sw * 0.011),
            Text('100% Secure', style: TextStyle(color: const Color(0XFF555555), fontSize: sw * 0.027, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    ],
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 2), blurRadius: 4)],
      ),
    ),
  );

  // ── STEPPER ───────────────────────────────────────
  Widget _buildStepper(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.015),
        child: SizedBox(
          width: sw * 0.693,
          child: Column(
            children: [
              Row(
                children: [
                  // Step 1 - done
                  Container(
                    width: sw * 0.059, height: sw * 0.059,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFAAB5FF)),
                    child: Icon(Icons.check, size: sw * 0.037, color: const Color(0xff4256D3)),
                  ),
                  Expanded(child: Container(height: 1.5, color: const Color(0xff4256D3))),
                  // Step 2 - done
                  Container(
                    width: sw * 0.059, height: sw * 0.059,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFAAB5FF)),
                    child: Icon(Icons.check, size: sw * 0.037, color: const Color(0xff4256D3)),
                  ),
                  Expanded(child: Container(height: 1.5, color: const Color(0xFF4256D3))),
                  // Step 3 - active
                  Container(
                    width: sw * 0.059, height: sw * 0.059,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4256D3),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text('3', style: TextStyle(color: Colors.white, fontSize: sw * 0.032, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.007),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Address', style: TextStyle(fontSize: sw * 0.027, fontWeight: FontWeight.w500, color: const Color(0xff4256D3))),
                  Text('Order Summary', style: TextStyle(fontSize: sw * 0.027, fontWeight: FontWeight.w500, color: const Color(0xff4256D3))),
                  Text('Payment', style: TextStyle(fontSize: sw * 0.027, fontWeight: FontWeight.w500, color: const Color(0xff555555))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOTAL BAR ─────────────────────────────────────
  Widget _buildTotalBar(double sw, double sh) {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _totalExpanded = !_totalExpanded),
            child: Container(
              width: sw * 0.800, // ~300
              height: sh * 0.062, // ~50
              padding: EdgeInsets.symmetric(horizontal: sw * 0.027),
              decoration: BoxDecoration(
                color: const Color(0XFFDCE1FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0XFFDCE1FF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w600, color: const Color(0xFF1C36CE)),
                      ),
                      SizedBox(width: sw * 0.005),
                      Icon(
                        _totalExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: sw * 0.053,
                        color: const Color(0xFF1C36CE),
                      ),
                    ],
                  ),
                  Text(
                    '₹${widget.totalAmount.toInt()}',
                    style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w600, color: const Color(0xFF1C36CE)),
                  ),
                ],
              ),
            ),
          ),
          if (_totalExpanded)
            Padding(
              padding: EdgeInsets.only(top: sh * 0.010),
              child: Container(
                width: sw * 0.747,
                padding: EdgeInsets.all(sw * 0.021),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    _breakdownRow('MRP', '₹5000', Colors.black, sw),
                    SizedBox(height: sh * 0.004),
                    _breakdownRow('Fees', '₹7', Colors.black, sw),
                    SizedBox(height: sh * 0.004),
                    _breakdownRow('Discount', '-₹2000', kGreen, sw),
                    SizedBox(height: sh * 0.004),
                    _breakdownRow('Total Amount', '₹5007', Colors.black, sw),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String val, Color valColor, double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: sw * 0.035, color: const Color(0xFF555555))),
        Text(val, style: TextStyle(fontSize: sw * 0.035, color: valColor, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── PAY SECTION ───────────────────────────────────
  Widget _buildPaySection({
    required PayMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    String? offerText,
    required Widget child,
    required double sw,
    required double sh,
  }) {
    final isOpen = _expanded == method;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.032, vertical: sh * 0.005),
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = isOpen ? null : method),
            child: Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.032, sh * 0.010, sw * 0.032, sh * 0.005),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: sw * 0.059, color: const Color(0xFF444444)),
                  SizedBox(width: sw * 0.032),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: sw * 0.037, fontWeight: FontWeight.w400, color: const Color(0xFF000000))),
                        if (!isOpen && subtitle.isNotEmpty)
                          Text(subtitle, maxLines: 1, style: TextStyle(fontSize: sw * 0.035, color: const Color(0xFF000000), fontWeight: FontWeight.w400)),
                        if (!isOpen && offerText != null)
                          Padding(
                            padding: EdgeInsets.only(top: sh * 0.002),
                            child: Text(offerText, style: TextStyle(fontSize: sw * 0.029, color: const Color(0xff3C8E09), fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: sw * 0.059,
                    color: const Color(0xFF888888),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sw * 0.032),
              color: Colors.white,
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildUpiExpanded(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.radio_button_checked_outlined, size: sw * 0.053, color: kPrimary),
          SizedBox(width: sw * 0.027),
          Text('Google Pay', style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A1A))),
        ]),
        SizedBox(height: sh * 0.007),
        Row(children: [
          SizedBox(width: sw * 0.080),
          Icon(Icons.check, size: sw * 0.037, color: kGreen),
          SizedBox(width: sw * 0.011),
          Text(
            '₹35 discount applied',
            style: TextStyle(
              fontSize: sw * 0.029,
              color: kGreen,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: kGreen,
            ),
          ),
        ]),
        SizedBox(height: sh * 0.017),
        _payButton('Pay ₹${widget.totalAmount.toInt()}', () {}, sw, sh),
      ],
    );
  }

  Widget _buildCardExpanded(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'Note: ', style: TextStyle(fontSize: sw * 0.037, color: Colors.black, fontWeight: FontWeight.w400)),
              TextSpan(
                text: 'Please ensure your card can be used for online transaction. ',
                style: TextStyle(fontSize: sw * 0.032, color: const Color(0xFF555555), fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: 'Learn more',
                style: TextStyle(fontSize: sw * 0.032, color: const Color(0xFF1B2A89), fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.007),
        Container(
          padding: EdgeInsets.all(sw * 0.032),
          decoration: BoxDecoration(
            color: const Color(0XFFF1F8E9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardField('Card Number', _cardNumberCtrl, 'XXXX XXXX XXXX XXXX',
                  TextInputType.number, 19, sw, sh,
                  suffix: Padding(
                    padding: EdgeInsets.all(sw * 0.021),
                    child: Image.asset('assets/cart/card.png', width: sw * 0.064, height: sw * 0.064,
                        errorBuilder: (_, __, ___) => Icon(Icons.credit_card, size: sw * 0.064)),
                  )),
              SizedBox(height: sh * 0.015),
              Row(children: [
                Expanded(child: _cardField('Valid Thru', _validThruCtrl, 'MM/YY', TextInputType.datetime, 5, sw, sh)),
                SizedBox(width: sw * 0.032),
                Expanded(child: _cardField('CCV', _ccvCtrl, 'CCV', TextInputType.number, 3, sw, sh, obscure: true)),
              ]),
            ],
          ),
        ),
        SizedBox(height: sh * 0.017),
        _payButton('Pay ₹${widget.totalAmount.toInt()}', () {}, sw, sh),
      ],
    );
  }

  Widget _cardField(
      String label,
      TextEditingController ctrl,
      String hint,
      TextInputType type,
      int max,
      double sw,
      double sh, {
        bool obscure = false,
        Widget? suffix,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: sw * 0.032, fontWeight: FontWeight.w500, color: const Color(0xFF444444))),
        SizedBox(height: sh * 0.007),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLength: max,
          obscureText: obscure,
          style: TextStyle(fontSize: sw * 0.037),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.032, vertical: sh * 0.015),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF555555)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0XFFF1F8E9),
          ),
        ),
      ],
    );
  }

  Widget _buildCodExpanded(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due to handling costs, a nominal fee of ₹10 will be charged for orders placed using this option. Avoid this fee by paying online now.',
          style: TextStyle(fontSize: sw * 0.032, color: const Color(0xFF555555), height: 1.5),
        ),
        SizedBox(height: sh * 0.017),
        _payButton('Pay ₹${widget.totalAmount.toInt()}', () => _showCodBottomSheet(sw, sh), sw, sh),
      ],
    );
  }

  Widget _payButton(String label, VoidCallback onTap, double sw, double sh) {
    return SizedBox(
      width: sw * 0.800,
      height: sh * 0.049, // ~40
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffF4E219),
          foregroundColor: const Color(0xFF1A1A1A),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        child: Text(label, style: TextStyle(fontSize: sw * 0.037, fontWeight: FontWeight.w500)),
      ),
    );
  }
}