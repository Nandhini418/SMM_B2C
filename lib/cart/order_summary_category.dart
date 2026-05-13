import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:smm_power/cart/cart_state.dart';
import 'package:smm_power/cart/payment_category.dart';
import 'package:smm_power/navigation_source.dart';
import 'package:smm_power/saved_address/address_model.dart';
import 'package:smm_power/saved_address/address_store.dart';
import 'package:smm_power/saved_address/add_address_screen.dart';

const Color kPrimary = Color(0xFF283897);
const Color kYellow  = Color(0xFFFFCC00);
const Color kGreen   = Color(0xFF2E7D32);
const Color kRed     = Color(0xFFD32F2F);

class Order_Summary_Category extends StatefulWidget {
  final NavigationSource source;
  /// When coming from "Buy Now", pass a single item here.
  /// If null, the screen reads from cartNotifier as usual.
  final CartItemModel? buyNowItem;

  const Order_Summary_Category({
    super.key,
    this.source = NavigationSource.bottomNav,
    this.buyNowItem,
  });

  @override
  State<Order_Summary_Category> createState() => _Order_Summary_CategoryState();
}

class _Order_Summary_CategoryState extends State<Order_Summary_Category> {
  // ── ADDRESS ──────────────────────────────────────
  final _store = AddressStore.instance;
  int _selectedIndex = 0;
  bool _showFeeBreakdown = false;

  // ── Items: buy-now single item OR full cart ───────
  List<CartItemModel> get cartItems =>
      widget.buyNowItem != null ? [widget.buyNowItem!] : cartNotifier.value;

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
    // Only listen to cart changes when NOT in buy-now mode
    if (widget.buyNowItem == null) {
      cartNotifier.addListener(_onCartChanged);
    }
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await _store.load();
    final defaultIdx = _store.addresses.indexWhere((a) => a.isDefault);
    setState(() {
      _selectedIndex = defaultIdx >= 0 ? defaultIdx : 0;
    });
  }

  @override
  void dispose() {
    if (widget.buyNowItem == null) {
      cartNotifier.removeListener(_onCartChanged);
    }
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  /// Navigate to AddAddressScreen and reload on return.
  /// Address is saved into AddressStore.instance so it also
  /// appears in SavedAddressScreen.
  Future<void> _goToAddAddress() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (result != null) {
      await _store.add(result);
      final defaultIdx = _store.addresses.indexWhere((a) => a.isDefault);
      setState(() {
        _selectedIndex = defaultIdx >= 0 ? defaultIdx : 0;
      });
    }
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sh * 0.015),
                  _buildStepper(sw, sh),
                  const Divider(color: Color(0xff4256D3)),
                  _buildDeliveryCard(sw, sh),
                  const Divider(color: Color(0xff4256D3)),
                  // Always show items — cartItems is never empty in buy-now mode
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) =>
                        _buildProduct(cartItems[index], sw, sh),
                  ),
                  if (cartItems.isNotEmpty) _buildBill(sw, sh),
                  SizedBox(height: sh * 0.01),
                  if (cartItems.isNotEmpty) _buildDisclaimer(sw, sh),
                  SizedBox(height: sh * 0.015),
                  _buildBottomBar(sw, sh),
                  SizedBox(height: sh * 0.025),
                ],
              ),
            ),
          ),
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
      icon: const Icon(Icons.chevron_left, color: Color(0xff000000)),
    ),
    titleSpacing: 0,
    title: Text(
      'Order Summary',
      style: TextStyle(
        color: const Color(0xFF000000),
        fontSize: sw * 0.045,
        fontWeight: FontWeight.w500,
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 6),
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
          width: sw * 0.7,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: sw * 0.07,
                    height: sw * 0.07,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFAAB5FF),
                        border: Border.all(
                            color: const Color(0xFF4256D3), width: 2)),
                    child: Icon(Icons.check,
                        size: sw * 0.037,
                        color: const Color(0xff4256D3)),
                  ),
                  Expanded(
                      child: Container(
                          height: 1.5,
                          color: const Color(0xff4256D3))),
                  Container(
                    width: sw * 0.07,
                    height: sw * 0.07,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff4256D3)),
                    child: Center(
                      child: Text('2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 1.5,
                          color: const Color(0xFF555555))),
                  Container(
                    width: sw * 0.07,
                    height: sw * 0.07,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF555555),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text('3',
                          style: TextStyle(
                              color: const Color(0xFF555555),
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w500)),
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
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4256D3))),
                  Text('Order Summary',
                      style: TextStyle(
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff555555))),
                  Text('Payment',
                      style: TextStyle(
                          fontSize: sw * 0.035,
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
    final addresses = _store.addresses;
    final hasAddress = addresses.isNotEmpty;
    final addr = hasAddress
        ? addresses[_selectedIndex.clamp(0, addresses.length - 1)]
        : null;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.043, vertical: sh * 0.012),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasAddress
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery to: ',
                  style: TextStyle(
                      fontSize: sw * 0.036,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: sh * 0.006),
                Row(children: [
                  Text(
                    addr!.name,
                    style: TextStyle(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000)),
                  ),
                  SizedBox(width: sw * 0.03),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.013,
                        vertical: sh * 0.002),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE9DEDE),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      addr.type,
                      style: TextStyle(
                        color: const Color(0xFF555252),
                        fontSize: sw * 0.027,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: sh * 0.006),
                Text(
                  addr.shortAddress,
                  style: TextStyle(
                      fontSize: sw * 0.034,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555555)),
                ),
                SizedBox(height: sh * 0.004),
                if (addr.phone.isNotEmpty)
                  Text(
                    _formatPhone(addr.phone),
                    style: TextStyle(
                        fontSize: sw * 0.034,
                        color: const Color(0xFF555555)),
                  ),
              ],
            )
            // No address — message + Add button (handled by the right-side button)
                : Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: kPrimary, size: sw * 0.053),
                SizedBox(width: sw * 0.016),
                Expanded(
                  child: Text(
                    'Add a delivery address to continue',
                    style: TextStyle(
                      fontSize: sw * 0.034,
                      color: const Color(0xFF555555),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.027),
          // Show "Change" when address exists, "Add" when not
          hasAddress
              ? GestureDetector(
            onTap: () => _showAddressSheet(sw, sh),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.027, vertical: sh * 0.007),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xff999999)),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: sw * 0.035),
              ),
            ),
          )
              : GestureDetector(
            onTap: _goToAddAddress,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.027, vertical: sh * 0.007),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xff999999)),
              ),
              child: Text(
                'Add',
                style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: sw * 0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(double sw, double sh) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _buildAddressSheet(sw, sh),
    );
  }

  Widget _buildAddressSheet(double sw, double sh) {
    return StatefulBuilder(builder: (context, setSheetState) {
      final addresses = _store.addresses;

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
                        fontSize: sw * 0.043,
                        fontWeight: FontWeight.w600)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: sw * 0.053),
                ),
              ],
            ),
            SizedBox(height: sh * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saved address',
                    style: TextStyle(
                        fontSize: sw * 0.037,
                        fontWeight: FontWeight.w500)),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push<AddressModel>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddAddressScreen()),
                    );
                    if (result != null) {
                      await _store.add(result);
                      final defaultIdx = _store.addresses
                          .indexWhere((a) => a.isDefault);
                      setState(() {
                        _selectedIndex =
                        defaultIdx >= 0 ? defaultIdx : 0;
                      });
                    }
                  },
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
              ],
            ),
            SizedBox(height: sh * 0.012),
            Expanded(
              child: addresses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: sw * 0.133, color: Colors.grey),
                    SizedBox(height: sh * 0.012),
                    Text('No saved addresses',
                        style: TextStyle(
                            fontSize: sw * 0.040,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: sh * 0.006),
                    Text('Tap "Add New" above to add one',
                        style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  final isSelected = index == _selectedIndex;
                  return InkWell(
                    onTap: () {
                      setSheetState(() {});
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin:
                      EdgeInsets.only(bottom: sh * 0.010),
                      padding: EdgeInsets.all(sw * 0.035),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? kPrimary
                              : const Color(0xFFB7B7B7),
                          width: isSelected ? 1.5 : 1,
                        ),
                        color: isSelected
                            ? const Color(0xFFEEF0FB)
                            : Colors.white,
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Icon(
                            addr.type == 'Home'
                                ? Icons.home_outlined
                                : addr.type == 'Office'
                                ? Icons.work_outline
                                : Icons.location_on_outlined,
                            size: sw * 0.053,
                            color: isSelected
                                ? kPrimary
                                : const Color(0xFF555555),
                          ),
                          SizedBox(width: sw * 0.027),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(addr.name,
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize: sw * 0.037)),
                                  SizedBox(width: sw * 0.016),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: sw * 0.013,
                                        vertical: sh * 0.002),
                                    decoration: BoxDecoration(
                                      color:
                                      const Color(0xFFE0E0E0),
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: Text(addr.type,
                                        style: TextStyle(
                                            fontSize: sw * 0.027,
                                            fontWeight:
                                            FontWeight.w600)),
                                  ),
                                  if (addr.isDefault) ...[
                                    SizedBox(width: sw * 0.011),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: sw * 0.013,
                                          vertical: sh * 0.002),
                                      decoration: BoxDecoration(
                                        color:
                                        const Color(0xFF0A832A),
                                        borderRadius:
                                        BorderRadius.circular(
                                            4),
                                      ),
                                      child: Text('DEFAULT',
                                          style: TextStyle(
                                              fontSize: sw * 0.024,
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.w600)),
                                    ),
                                  ],
                                ]),
                                SizedBox(height: sh * 0.004),
                                Text(addr.shortAddress,
                                    style: TextStyle(
                                        fontSize: sw * 0.032,
                                        color: const Color(
                                            0xFF555555))),
                                SizedBox(height: sh * 0.002),
                                Text(
                                    '+91 ${_formatPhone(addr.phone)}',
                                    style: TextStyle(
                                        fontSize: sw * 0.030,
                                        color: const Color(
                                            0xFF777777))),
                              ],
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: _selectedIndex,
                            activeColor: kPrimary,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            onChanged: (v) {
                              setSheetState(() {});
                              setState(() => _selectedIndex = v!);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
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
      margin: EdgeInsets.symmetric(vertical: sh * 0.001),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(sw * 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sw * 0.267,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: sw * 0.213,
                    height: sw * 0.213,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF897F7F)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.imagePath.startsWith('http')
                          ? Image.network(
                        item.imagePath,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) =>
                        progress == null
                            ? child
                            : const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4256D3))),
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey),
                        ),
                      )
                          : Image.asset(
                        item.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.01),
                  // In buy-now mode, qty selector is read-only (qty is always 1)
                  if (!item.outOfStock && widget.buyNowItem == null)
                    Padding(
                      padding: EdgeInsets.only(left: sw * 0.025),
                      child: _buildQtySelector(item, sw, sh),
                    ),
                  if (!item.outOfStock && widget.buyNowItem != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: sw * 0.025, top: sh * 0.005),
                      child: Text(
                        'Qty: ${item.qty}',
                        style: TextStyle(
                            fontSize: sw * 0.03,
                            color: const Color(0xFF555555)),
                      ),
                    ),
                  if (item.deliveryDate != null)
                    Padding(
                      padding: EdgeInsets.only(
                          top: sh * 0.007, left: sw * 0.025),
                      child: Text(
                        item.deliveryDate!,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.01),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: sh * 0.009),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                          5,
                              (i) => Icon(
                            i < 4 ? Icons.star : Icons.star_half,
                            size: sw * 0.045,
                            color: const Color(0xFFCEC01D),
                          )),
                      SizedBox(width: sw * 0.05),
                      Text(
                        '4.3 (128 reviews)',
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: const Color(0xFF767676),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.009),
                  Wrap(
                    spacing: sw * 0.016,
                    runSpacing: sh * 0.004,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.discountPercent > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.013,
                            vertical: sh * 0.001,
                          ),
                          child: Text(
                            '${item.discountPercent}% OFF',
                            style: TextStyle(
                              color: const Color(0xFF52B157),
                              fontSize: sw * 0.034,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      if (item.originalPrice != item.price)
                        Text(
                          '₹${item.originalPrice.toInt()}',
                          style: TextStyle(
                              fontSize: sw * 0.034,
                              color: const Color(0xFF9F9F9F),
                              decoration: TextDecoration.lineThrough,
                              decorationColor:
                              const Color(0xFF9F9F9F)),
                        ),
                      Text(
                        '₹${item.price.toInt()}',
                        style: TextStyle(
                          fontSize: sw * 0.040,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF000000),
                        ),
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
              child:
              Text('${i + 1}', style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        );
        if (selected != null) cartNotifier.updateQty(item, selected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.010, vertical: sh * 0.003),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF555555)),
          borderRadius: BorderRadius.circular(2),
          color: Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Qty: ${item.qty}',
            style: TextStyle(
              color: const Color(0xFF555555),
              fontSize: sw * 0.03,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: sw * 0.010),
          Icon(Icons.arrow_drop_down,
              size: sw * 0.043, color: const Color(0xFF555555)),
        ]),
      ),
    );
  }

  // ── BILL SECTION ──────────────────────────────────
  Widget _buildBill(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.001),
      child: Center(
        child: Container(
          width: sw * 0.90,
          padding: EdgeInsets.all(sw * 0.035),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _billRow('MRP', '₹${_mrpTotal.toInt()}', sw, sh),
              SizedBox(height: sh * 0.012),
              DottedLine(
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1,
                  dashColor: const Color(0xFF555555)),
              SizedBox(height: sh * 0.012),
              Row(children: [
                Text('Fees', style: TextStyle(fontSize: sw * 0.04)),
                SizedBox(width: sw * 0.011),
                GestureDetector(
                  onTap: () => setState(
                          () => _showFeeBreakdown = !_showFeeBreakdown),
                  child: Icon(
                      _showFeeBreakdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: sw * 0.043),
                ),
                const Spacer(),
                Text('₹${_fees.toInt()}',
                    style: TextStyle(fontSize: sw * 0.04)),
              ]),
              if (_showFeeBreakdown)
                Padding(
                  padding: EdgeInsets.only(top: sh * 0.007),
                  child: Text('Platform fee',
                      style: TextStyle(
                          fontSize: sw * 0.035,
                          color: const Color(0xFF555555))),
                ),
              SizedBox(height: sh * 0.012),
              DottedLine(
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1,
                  dashColor: const Color(0xFF555555)),
              SizedBox(height: sh * 0.012),
              Row(children: [
                Text('Discount',
                    style: TextStyle(fontSize: sw * 0.04)),
                const Spacer(),
                Text('-₹${_discount.toInt()}',
                    style: TextStyle(
                        fontSize: sw * 0.04,
                        color: const Color(0xFF41A900),
                        fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: sh * 0.012),
              DottedLine(
                  dashLength: 4,
                  dashGapLength: 3,
                  lineThickness: 1,
                  dashColor: const Color(0xFF555555)),
              SizedBox(height: sh * 0.012),
              Row(children: [
                Text('Total Amount',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.04)),
                const Spacer(),
                Text('₹${_total.toInt()}',
                    style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: sh * 0.03),
              if (_savings > 0)
                Container(
                  padding: EdgeInsets.all(sw * 0.027),
                  decoration: BoxDecoration(
                      color: const Color(0xFFC9FACC),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/picture/correct.png',
                          height: 20),
                      SizedBox(width: sw * 0.016),
                      Text(
                        "You'll save ₹${_savings.toInt()} on this order",
                        style: TextStyle(
                            color: const Color(0xFF046B09),
                            fontWeight: FontWeight.w400,
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
        Text(title, style: TextStyle(fontSize: sw * 0.04)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: sw * 0.04,
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
                fontFamily: 'Poppins',
                fontSize: sw * 0.033,
                color: const Color(0xFF666666),
                height: 1.8),
            children: [
              const TextSpan(
                  text:
                  'By continuing with the order, you confirm that you are above 18 '),
              const TextSpan(
                  text: "years of age, and you agree to Aura's "),
              TextSpan(
                text: 'Terms of Use',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: sw * 0.033),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: sw * 0.033),
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
      padding: EdgeInsets.all(sw * 0.05),
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
                ),
              ),
              SizedBox(height: sh * 0.005),
              Row(children: [
                Text(
                  '₹${_total.toInt()}',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: sw * 0.05,
                      color: const Color(0xff000000)),
                ),
                SizedBox(width: sw * 0.011),
                Image.asset('assets/picture/info.png', height: sh * 0.019),
              ]),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4E219),
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05, vertical: sh * 0.005),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              // Guard: must have a saved address before proceeding to payment
              if (_store.addresses.isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please add a delivery address to proceed',
                    ),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Payment_Category(
                    totalAmount: _total,
                    mrpTotal: _mrpTotal,
                    discount: _discount,
                    fees: _fees,
                    source: widget.source,
                  ),
                ),
              );
            },
            child: Text(
              'Continue',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}