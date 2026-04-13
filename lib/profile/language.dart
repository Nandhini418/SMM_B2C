import 'package:flutter/material.dart';
import 'package:smm_power/bottom_navigation/bottom_nav.dart';

class LanguageScreen extends StatefulWidget {
  final String mobileNumber;
  const LanguageScreen({super.key, required this.mobileNumber});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  int _selectedIndex = 0;

  final List<Map<String, String>> languages = [
    {"title": "हिंदी", "sub": "Hindi"},
    {"title": "తెలుగు", "sub": "Telugu"},
    {"title": "ಕನ್ನಡ", "sub": "Kannada"},
    {"title": "বাংলা", "sub": "Bengali"},
    {"title": "മലയാളം", "sub": "Malayalam"},
    {"title": "English", "sub": "English"},
    {"title": "ગુજરાતી", "sub": "Gujarati"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔵 APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Color(0xFF4256D3)),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Choose language",
                  style: TextStyle(
                    color: Color(0xFF4256D3),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12,),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Color(0xFF555555),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 5,),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFF999999), width: 1.5),
                          ),
                          child: _selectedIndex == index
                              ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4256D3),
                              ),
                            ),
                          )
                              : null,
                        ),

                        const SizedBox(width: 20),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang["title"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang["sub"]!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔵 CONTINUE BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4256D3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainScaffold(
                        mobileNumber: widget.mobileNumber,
                      ))
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 30,)
        ],
      ),
    );
  }
}