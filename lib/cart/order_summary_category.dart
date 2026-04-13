import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:smm_power/cart/cart_state.dart';      // adjust path
import 'package:smm_power/cart/payment_category.dart';
import 'package:smm_power/navigation_source.dart';

const Color kPrimary = Color(0xFF283897);
const Color kYellow  = Color(0xFFFFCC00);
const Color kGreen   = Color(0xFF2E7D32);
const Color kRed     = Color(0xFFD32F2F);

class Order_Summary_Category extends StatefulWidget {
  final NavigationSource source;
  const Order_Summary_Category({super.key, this.source = NavigationSource.bottomNav});

  @override
  State<Order_Summary_Category> createState() => _Order_Summary_CategoryState();
}

class _Order_Summary_CategoryState extends State<Order_Summary_Category> {
  int _selectedAddress = 0;
  bool _showFeeBreakdown = false;

  final List<Map<String, String>> addresses = [
    {'name': 'Akhil', 'address': 'Irugur, Coimbatore, 641103', 'phone': '9876543210'},
    {'name': 'Dhoni', 'address': 'Coimbatore - 641103', 'phone': ''},
  ];

  // ── derived from cart ──────────────────────────────
  List<CartItemModel> get cartItems => cartNotifier.value;

  double get _mrpTotal =>
      cartItems.fold(0.0, (s, e) => s + e.originalPrice * e.qty);

  double get _discount =>
      cartItems.fold(0.0, (s, e) => s + (e.originalPrice - e.price) * e.qty);

  double get _fees => cartItems.isEmpty ? 0 : 7;

  double get _total => _mrpTotal - _discount + _fees;

  double get _savings => _discount - _fees;

  @override
  void initState() {
    super.initState();
    cartNotifier.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cartNotifier.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepper(sw, sh),
                  const Divider(color: Color(0xff4256D3)),
                  _buildDeliveryCard(sw, sh),
                  const Divider(color: Color(0xff4256D3)),
                  if (cartItems.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: sh * 0.060),
                      child: Center(
                        child: Text(
                          'Your cart is empty.',
                          style: TextStyle(
                            fontSize: sw * 0.040,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) =>
                          _buildProduct(cartItems[index], sw, sh),
                    ),
                  if (cartItems.isNotEmpty) _buildBill(sw, sh),
                  SizedBox(height: sh * 0.037),
                  if (cartItems.isNotEmpty) _buildDisclaimer(sw, sh),
                  SizedBox(height: sh * 0.025),
                ],
              ),
            ),
          ),
          _buildBottomBar(sw, sh),
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────
  AppBar _buildAppBar(double sw, double sh) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: Icon(Icons.arrow_back_ios_new,
          color: const Color(0xff000000), size: sw * 0.040),
    ),
    titleSpacing: 0,
    title: Text(
      'Order Summary',
      style: TextStyle(
        color: const Color(0xFF000000),
        fontSize: sw * 0.037,
        fontWeight: FontWeight.w500,
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
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
                  Container(
                    width: sw * 0.059,
                    height: sw * 0.059,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFAAB5FF),
                    ),
                    child: Icon(Icons.check, size: sw * 0.037, color: const Color(0xff4256D3)),
                  ),
                  Expanded(child: Container(height: 1.5, color: const Color(0xff4256D3))),
                  Container(
                    width: sw * 0.059,
                    height: sw * 0.059,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xff4256D3)),
                    child: Center(
                      child: Text('2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Expanded(child: Container(height: 1.5, color: const Color(0xFFE0E0E0))),
                  Container(
                    width: sw * 0.059,
                    height: sw * 0.059,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text('3',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.007),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Address',
                      style: TextStyle(
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4256D3))),
                  Text('Order Summary',
                      style: TextStyle(
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff555555))),
                  Text('Payment',
                      style: TextStyle(
                          fontSize: sw * 0.027,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff555555))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DELIVERY CARD ─────────────────────────────────
  Widget _buildDeliveryCard(double sw, double sh) {
    final addr = addresses.isNotEmpty ? addresses[_selectedAddress] : null;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.043, vertical: sh * 0.012),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery to: ',
                    style: TextStyle(
                        fontSize: sw * 0.032,
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w600)),
                SizedBox(height: sh * 0.006),
                Row(children: [
                  Text(addr?['name'] ?? '',
                      style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A))),
                  SizedBox(width: sw * 0.016),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.016, vertical: sh * 0.002),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE9DEDE),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('Home',
                        style: TextStyle(
                            fontSize: sw * 0.027,
                            fontWeight: FontWeight.w400)),
                  ),
                ]),
                SizedBox(height: sh * 0.006),
                Text(addr?['address'] ?? '',
                    style: TextStyle(
                        fontSize: sw * 0.032, fontWeight: FontWeight.w400)),
                if ((addr?['phone'] ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: sh * 0.006),
                    child: Text(addr!['phone']!,
                        style: TextStyle(
                            fontSize: sw * 0.032, color: Colors.grey)),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => _buildAddressSheet(sw, sh),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.027, vertical: sh * 0.007),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xff999999)),
              ),
              child: Text('Change',
                  style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.035)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSheet(double sw, double sh) {
    return StatefulBuilder(builder: (context, setSheetState) {
      return Container(
        padding: EdgeInsets.all(sw * 0.043),
        height: sh * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select delivery address',
                    style: TextStyle(
                        fontSize: sw * 0.043, fontWeight: FontWeight.w600)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: sw * 0.053),
                ),
              ],
            ),
            SizedBox(height: sh * 0.012),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Saved address',
                  style: TextStyle(
                      fontSize: sw * 0.037, fontWeight: FontWeight.w500)),
              InkWell(
                onTap: () {},
                child: Row(children: [
                  Icon(Icons.add, size: sw * 0.043, color: kPrimary),
                  SizedBox(width: sw * 0.011),
                  Text('Add New',
                      style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: sw * 0.037)),
                ]),
              ),
            ]),
            SizedBox(height: sh * 0.012),
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  return ListTile(
                    leading: Icon(Icons.home_outlined, size: sw * 0.053),
                    title: Row(children: [
                      Text(addr['name']!,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: sw * 0.037)),
                      SizedBox(width: sw * 0.016),
                      if (_selectedAddress == index)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.016, vertical: sh * 0.002),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Currently selected',
                              style: TextStyle(
                                  fontSize: sw * 0.027,
                                  color: Colors.black)),
                        ),
                    ]),
                    subtitle: Text(addr['address']!,
                        style: TextStyle(fontSize: sw * 0.032)),
                    onTap: () {
                      setState(() => _selectedAddress = index);
                      Navigator.pop(context);
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          setSheetState(() {
                            addresses.removeAt(index);
                            if (_selectedAddress >= addresses.length) {
                              _selectedAddress = addresses.isEmpty
                                  ? 0
                                  : addresses.length - 1;
                            }
                          });
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit',
                                style: TextStyle(fontSize: sw * 0.037))),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: TextStyle(fontSize: sw * 0.037))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── PRODUCT ITEM ──────────────────────────────────
  Widget _buildProduct(CartItemModel item, double sw, double sh) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: sh * 0.005),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(sw * 0.027),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sw * 0.267,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.imagePath,
                      width: sw * 0.213,
                      height: sw * 0.213,
                      errorBuilder: (_, __, ___) => Container(
                        width: sw * 0.213,
                        height: sw * 0.213,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_outlined,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.010),
                  // Qty selector
                  Padding(
                    padding: EdgeInsets.only(left: sw * 0.027),
                    child: _buildQtySelector(item, sw, sh),
                  ),
                  if (item.deliveryDate != null)
                    Padding(
                      padding:
                      EdgeInsets.only(top: sh * 0.007, left: sw * 0.027),
                      child: Text(
                        item.deliveryDate!,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: sw * 0.027,
                            color: const Color(0xFF777777)),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.021),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: sw * 0.037,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF000000)),
                  ),
                  SizedBox(height: sh * 0.007),
                  Row(children: [
                    ...List.generate(
                        5,
                            (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_half,
                          size: sw * 0.032,
                          color: const Color(0xFFFFCC00),
                        )),
                    SizedBox(width: sw * 0.011),
                    Text('4.3 (128 reviews)',
                        style: TextStyle(
                            fontSize: sw * 0.032,
                            color: const Color(0xFF767676))),
                  ]),
                  SizedBox(height: sh * 0.007),
                  Wrap(
                    spacing: sw * 0.013,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${item.discountPercent}% OFF',
                        style: TextStyle(
                            color: const Color(0xff52B157),
                            fontSize: sw * 0.032,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        '₹${item.originalPrice.toInt()}',
                        style: TextStyle(
                          fontSize: sw * 0.029,
                          color: const Color(0xFF999999),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '₹${item.price.toInt()}',
                        style: TextStyle(
                            fontSize: sw * 0.053,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF000000)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtySelector(CartItemModel item, double sw, double sh) {
    return GestureDetector(
      onTapDown: (details) async {
        final selected = await showMenu<int>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: List.generate(
            5,
                (i) => PopupMenuItem<int>(
              value: i + 1,
              child: Text('${i + 1}',
                  style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        );
        if (selected != null) cartNotifier.updateQty(item, selected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.011, vertical: sh * 0.002),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(2),
          color: Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Qty: ${item.qty}',
              style: TextStyle(
                  fontSize: sw * 0.032, fontWeight: FontWeight.w400)),
          SizedBox(width: sw * 0.011),
          Icon(Icons.keyboard_arrow_down, size: sw * 0.043),
        ]),
      ),
    );
  }

  // ── BILL SECTION ──────────────────────────────────
  Widget _buildBill(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.032),
      child: Center(
        child: Container(
          width: sw * 0.90,
          padding: EdgeInsets.all(sw * 0.032),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _billRow('MRP', '₹${_mrpTotal.toInt()}', sw, sh),
              SizedBox(height: sh * 0.012),
              DottedLine(
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1,
                  dashColor: Colors.grey),
              SizedBox(height: sh * 0.012),
              Row(children: [
                Text('Fees', style: TextStyle(fontSize: sw * 0.037)),
                SizedBox(width: sw * 0.011),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showFeeBreakdown = !_showFeeBreakdown),
                  child: Icon(
                      _showFeeBreakdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: sw * 0.043),
                ),
                const Spacer(),
                Text('₹${_fees.toInt()}',
                    style: TextStyle(fontSize: sw * 0.037)),
              ]),
              if (_showFeeBreakdown)
                Padding(
                  padding: EdgeInsets.only(top: sh * 0.007),
                  child: Text('Platform fee',
                      style: TextStyle(
                          fontSize: sw * 0.032, color: Colors.grey)),
                ),
              SizedBox(height: sh * 0.012),
              DottedLine(
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1,
                  dashColor: Colors.grey),
              SizedBox(height: sh * 0.012),
              Row(children: [
                Text('Discount', style: TextStyle(fontSize: sw * 0.037)),
                const Spacer(),
                Text('-₹${_discount.toInt()}',
                    style: TextStyle(
                        fontSize: sw * 0.037,
                        color: kGreen,
                        fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: sh * 0.012),
              DottedLine(
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1,
                  dashColor: Colors.grey),
              SizedBox(height: sh * 0.012),
              Row(children: [
                Text('Total Amount',
                    style: TextStyle(fontSize: sw * 0.037)),
                const Spacer(),
                Text('₹${_total.toInt()}',
                    style: TextStyle(
                        fontSize: sw * 0.037,
                        fontWeight: FontWeight.bold)),
              ]),
              SizedBox(height: sh * 0.018),
              if (_savings > 0)
                Container(
                  padding: EdgeInsets.all(sw * 0.027),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          color: kGreen, size: sw * 0.048),
                      SizedBox(width: sw * 0.016),
                      Text(
                        "You'll save ₹${_savings.toInt()} on this order",
                        style: TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.w500,
                            fontSize: sw * 0.037),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billRow(String title, String value, double sw, double sh,
      {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh * 0.005),
      child: Row(children: [
        Text(title, style: TextStyle(fontSize: sw * 0.037)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: sw * 0.037,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  // ── DISCLAIMER ────────────────────────────────────
  Widget _buildDisclaimer(double sw, double sh) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: sw * 0.90,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: sw * 0.029,
                color: const Color(0xFF666666),
                height: 1.5),
            children: [
              const TextSpan(
                  text:
                  'By continuing with the order, you confirm that you are above 18\n'),
              const TextSpan(text: "years of age, and you agree to Aura's "),
              TextSpan(
                text: 'Terms of Use',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: sw * 0.029),
              ),
              const TextSpan(text: ' and\n'),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: sw * 0.029),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────
  Widget _buildBottomBar(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.032),
      decoration:
      BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${_mrpTotal.toInt()}',
                style: TextStyle(
                  fontSize: sw * 0.037,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff9F9F9F),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: const Color(0xff9F9F9F),
                  decorationThickness: 1.5,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Row(children: [
                Text(
                  '₹${_total.toInt()}',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: sw * 0.053,
                      color: const Color(0xff000000)),
                ),
                SizedBox(width: sw * 0.011),
                Icon(Icons.info_outline,
                    size: sw * 0.043, color: const Color(0xff9F9F9F)),
              ]),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.064, vertical: sh * 0.015),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: cartItems.isEmpty
                ? null
                : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Payment_Category(
                    totalAmount: _total, source: widget.source),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: sw * 0.037,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}