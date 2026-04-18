import 'package:flutter/material.dart';

class CustomerSupportPage extends StatefulWidget {
  const CustomerSupportPage({super.key});

  @override
  State<CustomerSupportPage> createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  final TextEditingController _feedbackController = TextEditingController();

  // ── FAQ expand state ──
  final List<bool> _expanded = List.filled(6, false);

  final List<Map<String, String>> _faqs = [
    {
      'q': '1. What products are available in the solar store?',
      'a':
      'We offer a wide range of solar products including solar panels, inverters, batteries, solar lights, water heaters, and complete solar kits for homes and businesses.',
    },
    {
      'q': '2. Do you provide installation services?',
      'a':
      'You can use our "Solar Calculator" or consult our experts to select a system based on your electricity usage, location, and budget.',
    },
    {
      'q': '3. Is there any warranty on solar products?',
      'a':
      'Yes, all products come with manufacturer warranties. Solar panels typically have 20–25 years performance warranty, while other components vary by brand.',
    },
    {
      'q': '4. What payment options are available?',
      'a':
      'We support multiple payment methods including UPI, credit/debit cards, net banking, EMI options, and cash on delivery (for selected products).',
    },
    {
      'q': '5. Can I return or replace a product?',
      'a':
      'Yes, we have an easy return and replacement policy within 7 days of delivery for damaged or defective products.',
    },
    {
      'q': '6. How long does delivery take?',
      'a':
      'Delivery usually takes 3–7 business days depending on your location. Installation (if selected) will be scheduled after delivery.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            _buildGstCard(),
            const SizedBox(height: 25),
            InsetDivider(),
            SizedBox(height: 25),
            _buildCallSection(),
            const SizedBox(height: 20),
            _buildEmailSection(),
            const SizedBox(height: 20),
            _buildFeedbackSection(),
            const SizedBox(height: 25),
           InsetDivider(),
            const SizedBox(height: 25),
            _buildFaqSection(),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left,
            color: Color(0xFF4256D3)),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: const Text(
        '24x7 Customer support',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFF4256D3),
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGstCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      height: 74,
      decoration: BoxDecoration(
        color: Color(0x80DCE1FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Container(
            width: 32,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFDCE1FF).withOpacity(0.4),
            ),
            child: Image.asset('assets/support/coin.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GST Rate Updates',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
                const Text(
                  'Quick answers to all your queries',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 2.2,
                    letterSpacing: 0,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Know more →',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF172997),
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
  Widget _buildCallSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Call Us Directly',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletRow(
            icon: null,
            text: 'Speak with our customer care team for urgent help.',
          ),
          const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 12),
            const Text(
              '•',
              style: TextStyle(
                fontSize: 14,
                height: 1,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 20,
              height: 20,
              child: Image.asset('assets/support/call.png'),
            ),
            const SizedBox(width: 8),
            const Text(
              'Customer Support: +91-90873-90873',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
          const SizedBox(height: 6),
          _buildBulletRow(
            icon: null,
            text: 'Available 9 AM – 9 PM IST',
          ),
        ],
      ),
    );
  }
  Widget _buildEmailSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email Support',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletRow(
            icon: null,
            text: 'For detailed queries or document submissions.',
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 12),
              Text(
                '•',
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '📧 support@truemotors.com',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildFeedbackSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback & Suggestions',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share your feedback to help us\nimprove your TrueMotors experience.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF000000), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: InputBorder.none,
                hintText: 'Write your feedback...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF742B88),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text(
                'Submit a Feedback',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'What Issues are you facing?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // ❗ No padding here
        ...List.generate(_faqs.length, (i) => _buildFaqItem(i)),
      ],
    );
  }

  Widget _buildFaqItem(int index) {
    final bool isOpen = _expanded[index];
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded[index] = !_expanded[index]),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isOpen
                        ? Colors.transparent
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _faqs[index]['q']!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEDEDED),
              border: const Border(
                top: BorderSide( // 👈 THIS IS THE DIVIDER
                  color: Color(0xFFBDBDBD),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              _faqs[index]['a']!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          crossFadeState:
          isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
  // ─────────────────────────────────────────
  // HELPER — bullet row
  // ─────────────────────────────────────────
  Widget _buildBulletRow({IconData? icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 12),
        const Text('•   ',
            style: TextStyle(fontSize: 14, color: Colors.black87)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}

class InsetDivider extends StatelessWidget {
  final double height;
  final double shadowHeight;
  final Color backgroundColor;
  final Color shadowColor;

  const InsetDivider({
    super.key,
    this.height = 6,
    this.shadowHeight = 2,
    this.backgroundColor = const Color(0xFFD3D3D3),
    this.shadowColor = const Color(0x40000000),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: backgroundColor,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: shadowHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    shadowColor,
                    shadowColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}