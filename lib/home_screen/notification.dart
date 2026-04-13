import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF1565C0),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Notification',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        children: const [
          SizedBox(height: 15),
          _NotificationCard(
            title: 'Your Order Flying Drone has been delivered!',
            subtitle: 'We hope your products reached you',
            time: '1 hrs ago',
            image: 'assets/home/flying_crane.png',
          ),
          SizedBox(height: 10),
          _NotificationCard(
            title: 'Your Order Solar Wall Light has been delivered!',
            subtitle: 'We hope your products reached you',
            time: '1 hrs ago',
            image: 'assets/home/solar_wall.png',
          ),
          SizedBox(height: 10),
          _NotificationCard(
            title: 'Your Order Solar Bollard has been delivered!',
            subtitle: 'We hope your products reached you',
            time: '1 hrs ago',
            image: 'assets/home/image_1.png',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String image;
  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.image,
});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF555555), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFFBDBDBD),
                    width: 1.5
                  )
                ),
                child: ClipOval(
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(title,
                     style: TextStyle(
                       fontSize: 15,
                       fontWeight: FontWeight.w500
                     ),
                   ),
                    const SizedBox(height: 4),
                    const Text(
                      'We hope your products reached you',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 🔥 TIME (below image, left aligned)
          const Padding(
            padding: EdgeInsets.only(left: 0),
            child: Text(
              '1 hrs ago',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}