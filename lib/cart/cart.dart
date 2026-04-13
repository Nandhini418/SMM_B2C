import 'package:flutter/material.dart';
import 'package:smm_power/cart/order_summary_category.dart';
import 'package:smm_power/navigation_source.dart';
import 'cart_state.dart';

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
  List<Map<String, String>> _addresses = [
    {"name": "Akhil", "address": "Irugur, Coimbatore"},
    {"name": "Dhoni", "address": "Gandhipuram, Coimbatore"},
  ];
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(sw, sh),
      body: _items.isEmpty
          ? _buildEmptyCart(sw, sh)
          : Column(
        children: [
          Expanded(
            child: ListView(
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
          _buildSavingsBar(sw, sh),
          _buildBottomBar(sw, sh),
        ],
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────
  Widget _buildEmptyCart(double sw, double sh) {
    return Column(
      children: [
        // show delivery address even when empty
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
      icon: Icon(Icons.arrow_back_ios_new,
          color: const Color(0xff000000), size: sw * 0.040),
    ),
    titleSpacing: 0,
    title: Text(
      'CART',
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

  // ── DELIVERY BANNER ───────────────────────────────
  Widget _buildDeliveryBanner(double sw, double sh) {
    final addr = _addresses.isNotEmpty ? _addresses[_selectedIndex] : null;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.043,
        vertical: sh * 0.012,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    'Delivery to: ',
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    addr != null ? '${addr['name']!}_638702' : '-',
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(width: sw * 0.016),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.016,
                      vertical: sh * 0.002,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: sw * 0.029,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: sh * 0.005),
                Text(
                  addr?['address'] ?? '',
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => _buildAddressSheet(),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.027,
                vertical: sh * 0.007,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xff999999)),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.035,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CART CARD ─────────────────────────────────────
  Widget _buildCartCard(CartItemModel item, int index, double sw, double sh) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: sh * 0.005),
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
                            child: const Icon(Icons.image_outlined, color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.007),
                      if (!item.outOfStock)
                        Padding(
                          padding: EdgeInsets.only(left: sw * 0.027),
                          child: _buildQtySelector(item, sw, sh),
                        ),
                      if (item.deliveryDate != null)
                        Padding(
                          padding: EdgeInsets.only(top: sh * 0.007, left: sw * 0.027),
                          child: Text(
                            item.deliveryDate!,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: sw * 0.027,
                              color: const Color(0xFF777777),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: sw * 0.032),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF000000),
                        ),
                      ),
                      SizedBox(height: sh * 0.007),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < 4 ? Icons.star : Icons.star_half,
                            size: sw * 0.032,
                            color: const Color(0xFFFFCC00),
                          )),
                          SizedBox(width: sw * 0.011),
                          Text(
                            '4.3 (128 reviews)',
                            style: TextStyle(
                              fontSize: sw * 0.032,
                              color: const Color(0xFF767676),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.007),
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
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${item.discountPercent}% OFF',
                              style: TextStyle(
                                color: kGreen,
                                fontSize: sw * 0.027,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
                              fontSize: sw * 0.040,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
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
            _actionCell(Icons.delete_outline, 'Remove', () {
              cartNotifier.removeItem(item);
            }, sw, sh),
            _actionCell(Icons.bookmark_border, 'Save for later', () {}, sw, sh),
            _actionCell(Icons.flash_on, 'Buy this now', () {}, sw, sh),
          ]),
        ],
      ),
    );
  }

  Widget _buildActionRow(List<Widget> cells) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              Expanded(child: cells[i]),
              if (i < cells.length - 1)
                Container(width: 1, color: const Color(0xFFEEEEEE)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionCell(IconData icon, String label, VoidCallback onTap,
      double sw, double sh) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.012),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: sw * 0.037, color: const Color(0xFF555555)),
            SizedBox(width: sw * 0.011),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: sw * 0.029, color: const Color(0xFF444444)),
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
          horizontal: sw * 0.011,
          vertical: sh * 0.002,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(2),
          color: Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Qty: ${item.qty}',
              style: TextStyle(fontSize: sw * 0.032, fontWeight: FontWeight.w400)),
          SizedBox(width: sw * 0.011),
          Icon(Icons.keyboard_arrow_down, size: sw * 0.043),
        ]),
      ),
    );
  }

  Widget _buildSavingsBar(double sw, double sh) => Container(
    color: const Color(0xFFE8F5E9),
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.043,
      vertical: sh * 0.010,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.circle, size: 10, color: kGreen),
        SizedBox(width: sw * 0.016),
        Text(
          "You'll save ₹${_savings.toInt()} on this order",
          style: TextStyle(
            color: kGreen,
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w600,
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
                  color: const Color(0xFF999999),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  '₹${_total.toInt()}',
                  style: TextStyle(
                    fontSize: sw * 0.053,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(width: sw * 0.011),
                Icon(Icons.info_outline, size: sw * 0.037, color: const Color(0xFFAAAAAA)),
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
              backgroundColor: kYellow,
              foregroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.075,
                vertical: sh * 0.017,
              ),
              elevation: 0,
            ),
            child: Text(
              'Place order',
              style: TextStyle(fontSize: sw * 0.040, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSheet() {
    return StatefulBuilder(builder: (context, setSheetState) {
      final mq = MediaQuery.of(context);
      final sw = mq.size.width;
      final sh = mq.size.height;

      return Container(
        padding: EdgeInsets.all(sw * 0.043),
        height: sh * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select delivery address',
                  style: TextStyle(fontSize: sw * 0.043, fontWeight: FontWeight.w600),
                ),
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
                    style: TextStyle(fontSize: sw * 0.037, fontWeight: FontWeight.w500)),
                InkWell(
                  onTap: () {},
                  child: Row(children: [
                    Icon(Icons.add, size: sw * 0.043, color: kPrimary),
                    SizedBox(width: sw * 0.011),
                    Text('Add New',
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: sw * 0.037,
                        )),
                  ]),
                ),
              ],
            ),
            SizedBox(height: sh * 0.012),
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final addr = _addresses[index];
                  return ListTile(
                    leading: Icon(Icons.home_outlined, size: sw * 0.053),
                    title: Row(children: [
                      Text(addr['name']!,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: sw * 0.037)),
                      SizedBox(width: sw * 0.016),
                      if (index == _selectedIndex)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.016, vertical: sh * 0.002),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Currently selected',
                              style: TextStyle(fontSize: sw * 0.027)),
                        ),
                    ]),
                    subtitle: Text(addr['address']!,
                        style: TextStyle(fontSize: sw * 0.032)),
                    onTap: () => setSheetState(() => _selectedIndex = index),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          setSheetState(() {
                            _addresses.removeAt(index);
                            if (_selectedIndex >= _addresses.length) {
                              _selectedIndex = _addresses.length - 1;
                            }
                          });
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit', style: TextStyle(fontSize: sw * 0.037))),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(fontSize: sw * 0.037))),
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
}