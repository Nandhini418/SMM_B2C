import 'package:flutter/material.dart';
import 'package:smm_power/cart/order_summary_category.dart';
import 'package:smm_power/navigation_source.dart';
import 'package:smm_power/saved_address/add_address_screen.dart';
import 'cart_state.dart';
import 'package:smm_power/saved_address/address_model.dart';
import 'package:smm_power/saved_address/address_store.dart';

const Color kPrimary = Color(0xFF283897);
const Color kYellow  = Color(0xFFFFCC00);
const Color kGreen   = Color(0xFF2E7D32);
const Color kRed     = Color(0xFFD32F2F);

class CartPage extends StatefulWidget {
  final VoidCallback? onBack;
  final NavigationSource source;

  const CartPage({
    super.key,
    this.onBack,
    this.source = NavigationSource.bottomNav,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _store = AddressStore.instance;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    cartNotifier.addListener(_onCartChanged);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await _store.load();
    // Select the default address if available
    final defaultIdx = _store.addresses.indexWhere((a) => a.isDefault);
    setState(() {
      _selectedIndex = defaultIdx >= 0 ? defaultIdx : 0;
    });
  }

  @override
  void dispose() {
    cartNotifier.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  List<CartItemModel> get _items => cartNotifier.value;
  double get _total   => cartNotifier.total;
  double get _savings => cartNotifier.savings;

  /// Navigate to AddAddressScreen and reload when returning
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

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(sw, sh),
      body: _items.isEmpty
          ? _buildEmptyCart(sw, sh)
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildDeliveryBanner(sw, sh),
                SizedBox(height: sh * 0.010),
                ..._items.asMap().entries.map(
                      (e) => _buildCartCard(e.value, e.key, sw, sh),
                ),
                SizedBox(height: sh * 0.010),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildSavingsBar(sw, sh),
                SizedBox(height: sh * 0.005),
                Padding(
                  padding: EdgeInsets.only(bottom: sh * 0.03),
                  child: _buildBottomBar(sw, sh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(double sw, double sh) {
    return Column(
      children: [
        _buildDeliveryBanner(sw, sh),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: sw * 0.267,
                  color: const Color(0xFFD0D5F5),
                ),
                SizedBox(height: sh * 0.025),
                Text(
                  'Your cart is empty!',
                  style: TextStyle(
                    fontSize: sw * 0.053,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: sh * 0.010),
                Text(
                  'Add items to get started.',
                  style: TextStyle(
                    fontSize: sw * 0.037,
                    color: const Color(0xFF888888),
                  ),
                ),
                SizedBox(height: sh * 0.035),
                ElevatedButton(
                  onPressed: _handleBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283897),
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.093,
                      vertical: sh * 0.017,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.040,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── APP BAR ───────────────────────────────────────
  AppBar _buildAppBar(double sw, double sh) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      onPressed: _handleBack,
      icon: Icon(Icons.chevron_left,
          color: const Color(0xff000000)),
    ),
    titleSpacing: 0,
    title: Text(
      'CART',
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

  // ── DELIVERY BANNER ───────────────────────────────
  Widget _buildDeliveryBanner(double sw, double sh) {
    final addresses = _store.addresses;
    final hasAddress = addresses.isNotEmpty;
    final addr = hasAddress
        ? addresses[_selectedIndex.clamp(0, addresses.length - 1)]
        : null;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              sw * 0.06, sh * 0.025, sw * 0.06, sh * 0.015,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: hasAddress
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Delivery to:  ',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${addr!.name}, ${addr.pincode}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.005),
                      Text(
                        '${addr.locality}, ${addr.city}',
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF555555),
                        ),
                      ),
                      SizedBox(height: sh * 0.002),
                    ],
                  )
                  // AFTER
                      : _items.isEmpty
                      ? const SizedBox.shrink()
                      : Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: kPrimary,
                        size: sw * 0.053,
                      ),
                      SizedBox(width: sw * 0.016),
                      Expanded(
                        child: Text(
                          'Add a delivery address to continue',
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            color: const Color(0xFF555555),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: sw * 0.027),
                if (hasAddress)
                  GestureDetector(
                    onTap: () => _showAddressSheet(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.025,
                        vertical: sh * 0.005,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0xff999999)),
                      ),
                      child: Text(
                        'Change',
                        style: TextStyle(
                          color: const Color(0xFF4256D3),
                          fontWeight: FontWeight.w600,
                          fontSize: sw * 0.035,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // AFTER
          if (_items.isNotEmpty)
            Divider(
              color: const Color(0xFF4256D3),
              height: 2,
              thickness: 1,
            ),
        ],
      ),
    );
  }

  void _showAddressSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _buildAddressSheet(),
    );
  }

  // ── CART CARD ─────────────────────────────────────
  Widget _buildCartCard(CartItemModel item, int index, double sw, double sh) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: sh * 0.007, ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.hotDeal)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.027,
                vertical: sh * 0.004,
              ),
              color: const Color(0xFFDCFFC7),
              child: Text(
                'Hot deal',
                style: TextStyle(
                  color: const Color(0xFF046B09),
                  fontSize: sw * 0.029,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Padding(
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
                          border: Border.all(color: Color(0xFF897F7F)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.01),
                      if (!item.outOfStock)
                        Padding(
                          padding: EdgeInsets.only(left: sw * 0.025),
                          child: _buildQtySelector(item, sw, sh),
                        ),
                      if (item.deliveryDate != null)
                        Padding(
                          padding: EdgeInsets.only(top: sh * 0.007, left: sw * 0.025),
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
                          ...List.generate(5, (i) => Icon(
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
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.013,
                              vertical: sh * 0.001,
                            ),
                            child: Text(
                              '${item.discountPercent}% OFF',
                              style: TextStyle(
                                color: Color(0xFF52B157),
                                fontSize: sw * 0.034,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            '₹${item.originalPrice.toInt()}',
                            style: TextStyle(
                              fontSize: sw * 0.034,
                              color: const Color(0xFF9F9F9F),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xFF9F9F9F)
                            ),
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
          _buildActionRow([
            _actionCell('assets/picture/remove.png', 'Remove', () {
              cartNotifier.removeItem(item);
            }, sw, sh),
            _actionCell('assets/picture/save.png', 'Save for later', () {}, sw, sh),
            _actionCell('assets/picture/buy.png', 'Buy this now', () {}, sw, sh),
          ]),
        ],
      ),
    );
  }

  Widget _buildActionRow(List<Widget> cells) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF555555), width: 1),
          bottom: BorderSide(color: Color(0xFF555555), width: 1)
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              Expanded(child: cells[i]),
              if (i < cells.length - 1)
                Container(width: 1, color: const Color(0xFF555555)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionCell(String imagePath, String label, VoidCallback onTap,
      double sw, double sh) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.012),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: sw * 0.037,
              height: sw * 0.037,
              color: const Color(0xFF555555),
            ),
            SizedBox(width: sw * 0.011),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: sw * 0.03, color: const Color(0xFF444444)),
                overflow: TextOverflow.ellipsis,
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

              child: Text('${i + 1}', style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        );
        if (selected != null) cartNotifier.updateQty(item, selected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.010,
          vertical: sh * 0.003
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF555555)),
          borderRadius: BorderRadius.circular(2),
          color: Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Qty: ${item.qty}',
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: sw * 0.03, 
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: sw * 0.010),
          Icon(Icons.arrow_drop_down, size: sw * 0.043, color: Color(0xFF555555),),
        ]),
      ),
    );
  }

  Widget _buildSavingsBar(double sw, double sh) => Container(
    color: const Color(0xFFC9FACC),
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.043,
      vertical: sh * 0.010,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/picture/correct.png',
          height: sh * 0.02,
        ),
        SizedBox(width: sw * 0.016),
        Text(
          "You'll save ₹ ${_savings.toInt()} on this order",
          style: TextStyle(
            color: Color(0xFF046B09),
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomBar(double sw, double sh) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.043,
        vertical: sh * 0.012,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${(_total + _savings).toInt()}',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  color: const Color(0xFF9F9F9F),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFF9F9F9F)
                ),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  '₹${_total.toInt()}',
                  style: TextStyle(
                    fontSize: sw * 0.053,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(width: sw * 0.011),
                Image.asset('assets/picture/info.png',
                  height: sh * 0.02,
                )
              ]),
            ],
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Order_Summary_Category(source: widget.source),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF4E219),
              foregroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.075,
                vertical: sh * 0.015,
              ),
              elevation: 0,
            ),
            child: Text(
              'Place order',
              style: TextStyle(fontSize: sw * 0.040, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── ADDRESS BOTTOM SHEET ──────────────────────────
  Widget _buildAddressSheet() {
    return StatefulBuilder(builder: (context, setSheetState) {
      final mq = MediaQuery.of(context);
      final sw = mq.size.width;
      final sh = mq.size.height;
      final addresses = _store.addresses;

      return Container(
        padding: EdgeInsets.all(sw * 0.043),
        height: sh * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select delivery address',
                  style: TextStyle(
                      fontSize: sw * 0.043, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: sw * 0.053),
                ),
              ],
            ),
            SizedBox(height: sh * 0.012),

            // Saved address label + Add New button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved address',
                  style: TextStyle(
                      fontSize: sw * 0.037, fontWeight: FontWeight.w500),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context); // close sheet first
                    final result = await Navigator.push<AddressModel>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddAddressScreen()),
                    );
                    if (result != null) {
                      await _store.add(result);
                      final defaultIdx =
                      _store.addresses.indexWhere((a) => a.isDefault);
                      setState(() {
                        _selectedIndex =
                        defaultIdx >= 0 ? defaultIdx : 0;
                      });
                    }
                  },
                  child: Row(children: [
                    Icon(Icons.add, size: sw * 0.043, color: kPrimary),
                    SizedBox(width: sw * 0.011),
                    Text(
                      'Add New',
                      style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.037,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            SizedBox(height: sh * 0.012),

            // Address list or empty
            Expanded(
              child: addresses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: sw * 0.133, color: Colors.grey),
                    SizedBox(height: sh * 0.012),
                    Text(
                      'No saved addresses',
                      style: TextStyle(
                          fontSize: sw * 0.040,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: sh * 0.006),
                    Text(
                      'Tap "Add New" above to add one',
                      style: TextStyle(
                          fontSize: sw * 0.032, color: Colors.grey),
                    ),
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
                      margin: EdgeInsets.only(bottom: sh * 0.010),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    addr.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: sw * 0.037),
                                  ),
                                  SizedBox(width: sw * 0.016),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: sw * 0.013,
                                        vertical: sh * 0.002),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E0E0),
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      addr.type,
                                      style: TextStyle(
                                          fontSize: sw * 0.027,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  if (addr.isDefault) ...[
                                    SizedBox(width: sw * 0.011),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: sw * 0.013,
                                          vertical: sh * 0.002),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A832A),
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                            fontSize: sw * 0.024,
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ]),
                                SizedBox(height: sh * 0.004),
                                Text(
                                  addr.shortAddress,
                                  style: TextStyle(
                                      fontSize: sw * 0.032,
                                      color: const Color(0xFF555555)),
                                ),
                                SizedBox(height: sh * 0.002),
                                Text(
                                  '+91 ${_formatPhone(addr.phone)}',
                                  style: TextStyle(
                                      fontSize: sw * 0.030,
                                      color: const Color(0xFF777777)),
                                ),
                              ],
                            ),
                          ),
                          // Selected radio indicator
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
}