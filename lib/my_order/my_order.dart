import 'package:smm_power/my_order/review_product.dart';
import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF4256D3);
const Color kGreen = Color(0xFF007C29);
const Color kRed = Color(0xFFD32F2F);
const Color kYellow = Color(0xFFEE9300);

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────
enum OrderStatus { active, delivered, cancelled }

class OrderModel {
  final String id;
  final String productName;
  final String subtitle;
  final String imagePath;
  final double totalPaid;
  final String date;
  final OrderStatus status;
  final List<String> trackingSteps; // completed steps
  final bool hasFreeInstallation;

  const OrderModel({
    required this.id,
    required this.productName,
    required this.subtitle,
    required this.imagePath,
    required this.totalPaid,
    required this.date,
    required this.status,
    this.trackingSteps = const [],
    this.hasFreeInstallation = false,
  });
}

// ─────────────────────────────────────────
// SAMPLE DATA
// ─────────────────────────────────────────
final List<OrderModel> _allOrders = [
  OrderModel(
    id: 'SR-4398',
    productName: 'Flying Crane',
    subtitle: '30W · IP65 · Auto dusk-dawn',
    imagePath: 'assets/my_order/fly.png',
    totalPaid: 78000,
    date: 'Apr 4, 2026',
    status: OrderStatus.active,
    trackingSteps: ['Confirmed', 'Shipped'],
    hasFreeInstallation: true,
  ),
  OrderModel(
    id: 'SR-4399',
    productName: 'Flying Crane',
    subtitle: '30W · IP65 · Auto dusk-dawn',
    imagePath: 'assets/my_order/fly.png',
    totalPaid: 12400,
    date: 'Apr 4, 2026',
    status: OrderStatus.delivered,
  ),
  OrderModel(
    id: 'SR-4400',
    productName: 'Flying Crane',
    subtitle: '30W · IP65 · Auto dusk-dawn',
    imagePath: 'assets/my_order/fly.png',
    totalPaid: 78000,
    date: 'Apr 4, 2026',
    status: OrderStatus.cancelled,
  ),
];

// ─────────────────────────────────────────
// MY ORDERS PAGE
// ─────────────────────────────────────────
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}


class _MyOrdersPageState extends State<MyOrdersPage> {
  int _selectedTab = 0; // 0=All, 1=Active, 2=Delivered, 3=Cancelled
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = ['All Orders', 'Active', 'Delivered', 'Cancelled'];

  List<OrderModel> get _filteredOrders {
    List<OrderModel> list;
    switch (_selectedTab) {
      case 1:
        list = _allOrders.where((o) => o.status == OrderStatus.active).toList();
        break;
      case 2:
        list =
            _allOrders.where((o) => o.status == OrderStatus.delivered).toList();
        break;
      case 3:
        list =
            _allOrders.where((o) => o.status == OrderStatus.cancelled).toList();
        break;
      default:
        list = [..._allOrders];

        list.sort((a, b) {
          int getPriority(OrderStatus status) {
            switch (status) {
              case OrderStatus.delivered:
                return 0;
              case OrderStatus.active:
                return 1;
              case OrderStatus.cancelled:
                return 2;
            }
          }

          return getPriority(a.status).compareTo(getPriority(b.status));
        });
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((o) =>
      o.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.id.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildBanner(),

            const SizedBox(height: 10),
            _buildTabBar(),

            _filteredOrders.isEmpty
                ? const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text(
                'No orders found',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(_filteredOrders[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left,
            color: Color(0xFF4256D3)),
      ),
      titleSpacing: 0,
      title: const Text(
        'My Orders',
        style: TextStyle(
          color: Color(0xFF4256D3),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search,
              color: Color(0xFF4256D3), size: 22),
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // BANNER
  // ─────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
      width: 390,
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF4256D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/my_order/banner.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────
  Widget _buildTabBar() {
    // Tab widths from Figma
    final List<double> widths = [110, 70, 80, 72];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final bool isSelected = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                width: widths[index],
                height: 34,
                margin: EdgeInsets.only(
                    right: index < _tabs.length - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: isSelected ? kPrimary : const Color(0xFFADADAD),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Color(0XFF4256D3),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // ORDER CARD
  // ─────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0XFF4256D3),),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── MAIN ROW ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    order.imagePath,
                    width: 83,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_outlined,
                              color: Color(0xFFAAAAAA), size: 30),
                        ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${order.id} · ${order.date}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (order.status != OrderStatus.delivered)
                        Text(
                          order.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF000000),
                          ),
                        ),
                      const SizedBox(height: 6),

                      if (order.status == OrderStatus.delivered)
                        Text(
                          '₹${order.totalPaid.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── TRACKING STEPPER (Active orders) ──
          if (order.status == OrderStatus.active &&
              order.trackingSteps.isNotEmpty)
            _buildTrackingStepper(order),
          // ── FREE INSTALLATION BANNER ──
          if (order.hasFreeInstallation)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF568B3E),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                children: const [
                  Text(
                    'Free professional installation included — schedule after delivery',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

          if (order.status != OrderStatus.active)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFDADADA),
            ),

          const SizedBox(height: 10),
          _buildCardFooter(order),

          const SizedBox(height: 7),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color text;
    String label;
    switch (status) {
      case OrderStatus.active:
        bg = const Color(0xFFFEDE9A);
        text = const Color(0xFF000000);
        label = 'Shipped';
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFF98C89A);
        text = Color(0xFF000000);
        label = 'Delivered';
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFF4B588);
        text = Color(0xFF000000);
        label = 'Cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }

  Widget _buildTrackingStepper(OrderModel order) {
    final steps = ['Confirmed', 'Shipped', 'Out For\nDelivery', 'Delivered'];
    final completed = order.trackingSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (i) {
          final bool isDone =
          completed.contains(steps[i].replaceAll('\n', ' ').trim());
          final bool isCurrent = i == completed.length;
          final bool isFirst = i == 0;
          final bool isLast = i == steps.length - 1;

          // Circle colors
          Color circleColor;
          Color borderColor;
          if (isDone) {
            circleColor = kGreen;
            borderColor = kGreen;
          } else if (isCurrent) {
            circleColor = kYellow;
            borderColor = kYellow;
          } else {
            circleColor = Color(0XFFD9D9D9);
            borderColor = Color(0XFFD9D9D9);
          }

          final Color leftLineColor =
          (i > 0 && completed.length >= i) ? Color(0XFF000000) : Colors.black;
          final Color rightLineColor =
          (!isLast && completed.length > i) ? Colors.black : Colors.black;

          return Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isFirst
                                  ? Colors.transparent
                                  : leftLineColor,
                            ),
                          ),

                          const SizedBox(width: 22),
                          // RIGHT line segment
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isLast
                                  ? Colors.transparent
                                  : rightLineColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                          border: Border.all(
                            color: Color(0xFFFFFFFF),
                            width: 1.5,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check,
                            size: 12, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── LABEL ──
                Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.2,
                    color: Colors.black,
                    fontWeight:
                    FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCardFooter(OrderModel order) {
    switch (order.status) {
    // ───────── ACTIVE (SHIPPED) ─────────
      case OrderStatus.active:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total paid',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    '₹${order.totalPaid.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: const Text(
                  'Track Shipment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      case OrderStatus.delivered:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFFB031),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReviewProductPage(
                        product: ReviewProductModel(
                          productName: order.productName,
                          subtitle: order.subtitle,
                          imagePath: order.imagePath,
                        ),
                      ),
                    ),
                  );
                },

                child: const Text(
                  'Write Review',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 15),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.file_download_outlined,
                        size: 16, color: Color(0xFF4256D3)),
                    SizedBox(width: 3),
                    Text(
                      'Invoice',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: const Text(
                  'Reorder',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );

    // ───────── CANCELLED ─────────
      case OrderStatus.cancelled:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total paid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    '₹${order.totalPaid.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: const Text(
                  'Reorder',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

