import 'dart:ui';
import 'package:flutter/material.dart';

class SmmSupportPage extends StatefulWidget {
  const SmmSupportPage({super.key});

  @override
  State<SmmSupportPage> createState() => _SmmSupportPageState();
}

class _SmmSupportPageState extends State<SmmSupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'bot_text',
      'text': "Hey , I'm your Flipkart Support Assistant",
      'time': '12:21 pm',
    },
    {
      'type': 'bot_product',
      'productName': 'Flying Crane-solar-',
      'productSub': 'powered Street Are....',
      'time': '12:21 pm',
    },
    {
      'type': 'bot_text',
      'text': 'I see that your product is delivered to you',
      'time': '12:21 pm',
    },
    {
      'type': 'bot_options',
      'question': 'How may I help you?',
      'options': [
        'Order not delivered',
        'I need to return the item',
        'Get my bill or invoice',
        'Know more about SuperCoins',
        'Something else',
      ],
      'time': '12:21 pm',
    },
    {
      'type': 'user',
      'text': 'Is faster delivery possible?',
    },
  ];
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'type': 'user', 'text': text});
    });
    _messageController.clear();
  }
  String get _nowTime {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'am' : 'pm';
    return '$h:$m $period';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 25),
              children: [
                _buildTodaySection(),
                SizedBox(height: 30),
                ..._messages.map((msg) => _buildMessage(msg)),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4256D3), size: 16),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: const Text(
        'SMM Support',
        style: TextStyle(
          color: Color(0XFF4256D3),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
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
  }
  Widget _buildTodaySection() {
    return Column(
      children: [
        Container(
          width: 69,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Today',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 350,
          child: const Text(
            'Please excuse any mistakes as we work to better answe your questions. Do not give personal information in this chat',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF454141),
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildMessage(Map<String, dynamic> msg) {
    switch (msg['type']) {
      case 'bot_text':
        return _buildBotTextBubble(msg['text'], msg['time']);
      case 'bot_product':
        return _buildBotProductCard(
            msg['productName'], msg['productSub'], msg['time']);
      case 'bot_options':
        return _buildBotOptions(
            msg['question'], List<String>.from(msg['options']), msg['time']);
      case 'user':
        return _buildUserBubble(msg['text']);
      default:
        return const SizedBox();
    }
  }
  Widget _buildBotTextBubble(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 275,
          constraints: const BoxConstraints(minHeight: 45),
          padding: const EdgeInsets.fromLTRB(10, 14, 8, 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE1FF).withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF696262),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBotProductCard(String name, String sub, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 275,
          padding: const EdgeInsets.fromLTRB(10, 15, 8, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE1FF).withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 247,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 42,
                        height: 40,
                        child: ImageFiltered(
                          imageFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.45),
                            BlendMode.lighten,
                          ),
                          child: Image.asset(
                            'assets/my_order/fly.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE8EAF6),
                              child: const Icon(
                                Icons.light_outlined,
                                color: Color(0xFF4256D3),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Flying Crane-',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0XFF4256D3).withOpacity(0.5),
                                height: 1.4,
                              ),
                            ),
                            TextSpan(
                              text: 'solar-',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF4256D3).withOpacity(0.5),
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: 'powered Street Are....',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF4256D3).withOpacity(0.5),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(time,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF696262),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBotOptions(String question, List<String> options, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 275,
          padding: const EdgeInsets.fromLTRB(10, 14, 8, 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE1FF).withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ...options.map(
                    (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: 255,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFC8C8C8),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF162E88),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFF162E88),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF696262),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 195, minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF4256D3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInputBar() {
    return Stack(
      children: [
        Container(
          height: 90,
          color: Colors.white,
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 25,
          child: Container(
            height: 40,
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFF293896),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Write a message...',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Image(
                      image: AssetImage('assets/images/share.png'),
                      width: 24,
                      height: 24,
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}