import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CategoryScreen({super.key, this.onBack});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedSideIndex = 0;

  final List<_SideCategory> _sideCategories = const [
    _SideCategory(label: 'POPULAR', image: 'assets/category/star.png', color: Color(0xFF2E7D32)),
    _SideCategory(label: 'FLYING CRANE', image: 'assets/home/flying_crane.png', color: Color(0xFF1565C0)),
    _SideCategory(label: 'SOLAR BOLLARD', image: 'assets/home/image_1.png', color: Color(0xFF2E7D32)),
    _SideCategory(label: 'SOLAR POST TOP LIGHT', image: 'assets/home/solar_post.png', color: Color(0xFF388E3C)),
    _SideCategory(label: 'SOLAR WITH CCTV', image: 'assets/category/solar_cctv.png', color: Color(0xFF2E7D32)),
    _SideCategory(label: 'SOLAR WALL LIGHT', image: 'assets/category/solar_wall_light.png', color: Color(0xFF7B1FA2)),
    _SideCategory(label: 'SOLAR WIND HYBRID', image: 'assets/category/solar_hybrid.png', color: Color(0xFF0288D1)),
    _SideCategory(label: 'SOLAR SERIES PRODUCTS', image: 'assets/category/solar_series.png', color: Color(0xFF558B2F)),
  ];

  final List<_CategoryContent> _contents = const [
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'Features On SMM',
          items: [
            _ContentItem(label: 'SOLAR WITH\nCCTV', image: 'assets/category/solar_cctv.png'),
            _ContentItem(label: 'FLYING\nCRANE', image: 'assets/home/flying_crane.png'),
            _ContentItem(label: 'SOLAR WIND\nHYBRID', image: 'assets/category/solar_hybrid.png'),
            _ContentItem(label: 'SOLAR SERIES\nPRODUCTS', image: 'assets/category/solar_series.png'),
            _ContentItem(label: 'SOLAR POST\nTOP LIGHT', image: 'assets/home/solar_post.png'),
          ],
        ),
        _ContentSection(
          title: 'All Popular',
          items: [
            _ContentItem(label: 'SOLAR BOLLARD', image: 'assets/home/image_1.png'),
            _ContentItem(label: 'SOLAR WALL\nLIGHT', image: 'assets/category/solar_wall_light.png'),
            _ContentItem(label: 'SOLAR WIND\nHYBRID', image: 'assets/category/solar_hybrid.png'),
            _ContentItem(label: 'SOLAR SERIES\nPRODUCTS', image: 'assets/category/solar_series.png'),
            _ContentItem(label: 'SOLAR POST\nTOP LIGHT', image: 'assets/home/solar_post.png'),
          ],
        ),
        _ContentSection(
          title: 'Flying Crane',
          items: [
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 1', image: 'assets/category/flying_crane_1.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 2', image: 'assets/category/flying_crane_2.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 3', image: 'assets/category/flying_crane_4.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 4', image: 'assets/category/flying_crane_4.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 5', image: 'assets/home/flying_crane.png'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'Flying Crane',
          items: [
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 1', image: 'assets/category/flying_crane_1.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 2', image: 'assets/category/flying_crane_2.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 3', image: 'assets/category/flying_crane_4.png'),
            _ContentItem(label: 'FLYING CRANE\nPRODUCT 4', image: 'assets/category/flying_crane_3.png'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'Solar Bollard',
          items: [
            _ContentItem(label: 'SOLAR BOLLARD\nLIGHT 1', image: 'assets/home/bollard.png'),
            _ContentItem(label: 'SOLAR BOLLARD\nLIGHT 2', image: 'assets/items/solar_bollard.jpg'),
            _ContentItem(label: 'SOLAR BOLLARD\nLIGHT 3', image: 'assets/home/image_3.png'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'Solar Post Top Light',
          items: [
            _ContentItem(label: 'SOLAR POST\nTOP LIGHT 1', image: 'assets/items/solar_top_1.jpg'),
            _ContentItem(label: 'SOLAR POST\nTOP LIGHT 3', image: 'assets/items/solar_top_3.jpg'),
            _ContentItem(label: 'SOLAR POST\nTOP LIGHT 2', image: 'assets/items/solar_top_2.jpg'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'Solar with CCTV',
          items: [
            _ContentItem(label: 'SOLAR WITH\nCCTV 1', image: 'assets/items/solar_cctv_1.jpg'),
            _ContentItem(label: 'SOLAR WITH\nCCTV 2', image: 'assets/items/solar_cctv_2.jpg'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'Solar Wall Light',
          items: [
            _ContentItem(label: 'SOLAR WALL\nLIGHT 1', image: 'assets/items/solar_wall_light_1.jpg'),
            _ContentItem(label: 'SOLAR WALL\nLIGHT 2', image: 'assets/items/solar_wall_light_2.jpg'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'SOLAR WIND HYBRID',
          items: [
            _ContentItem(label: 'SOLAR WIND', image: 'assets/category/solar_hybrid.png'),
          ],
        ),
      ],
    ),
    _CategoryContent(
      sections: [
        _ContentSection(
          title: 'SOLAR SERIES PRODUCTS',
          items: [
            _ContentItem(label: 'FL SERIES ', image: 'assets/category/solar_series_1.jpg'),
            _ContentItem(label: 'MHL SERIES', image: 'assets/category/mhl.jpg'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(sh * 0.069), // ~56
        child: Container(
          decoration: const BoxDecoration(
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
              padding: EdgeInsets.symmetric(horizontal: sw * 0.032),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: const Color(0xFF000000), size: sw * 0.064),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                  SizedBox(width: sw * 0.011),
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: const Color(0xFF000000),
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search, size: sw * 0.064),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(sw, sh),
                  Expanded(child: _buildContent(sw, sh)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LEFT SIDEBAR ──────────────────────────────────
  Widget _buildSidebar(double sw, double sh) {
    return Container(
      width: sw * 0.219, // ~82
      color: const Color(0xFFE5FFE7),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _sideCategories.length,
        itemBuilder: (ctx, i) {
          final cat = _sideCategories[i];
          final isSelected = i == _selectedSideIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedSideIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFE5FFE7),
                border: Border(
                  left: BorderSide(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                    width: 3,
                  ),
                  bottom: const BorderSide(color: Color(0xFF4256D3)),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: sh * 0.015,
                horizontal: sw * 0.021,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: sw * 0.139,  // ~52
                    height: sw * 0.139,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(i == 0 ? 4 : sw * 0.027),
                      child: Transform.scale(
                        scale: i == 0 ? 0.8 : 1.2,
                        child: ClipOval(
                          child: Image.asset(
                            cat.image,
                            width: sw * 0.139,
                            height: sw * 0.139,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.007),
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sw * 0.029,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: const Color(0xFF4256D3),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── RIGHT CONTENT ─────────────────────────────────
  Widget _buildContent(double sw, double sh) {
    final content = _contents[_selectedSideIndex];

    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: EdgeInsets.all(sw * 0.032),
        itemCount: content.sections.length,
        itemBuilder: (ctx, si) {
          final section = content.sections[si];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * 0.012),
              Row(
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontSize: sw * 0.037,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(width: sw * 0.021),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFF4256D3)),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.017),
              _buildItemGrid(section.items, sw, sh),
              SizedBox(height: sh * 0.025),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemGrid(List<_ContentItem> items, double sw, double sh) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (ctx, i) => _ContentItemCard(item: items[i], sw: sw, sh: sh),
    );
  }
}

// ── ITEM CARD ─────────────────────────────────────────
class _ContentItemCard extends StatelessWidget {
  final _ContentItem item;
  final double sw;
  final double sh;
  const _ContentItemCard({required this.item, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: sw * 0.173,  // ~65
          height: sw * 0.173,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(item.image, fit: BoxFit.contain),
            ),
          ),
        ),
        SizedBox(height: sh * 0.007),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sw * 0.027,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF000000),
          ),
        ),
      ],
    );
  }
}

// ── DATA MODELS ───────────────────────────────────────
class _SideCategory {
  final String label;
  final String image;
  final Color color;
  const _SideCategory({required this.label, required this.image, required this.color});
}

class _CategoryContent {
  final List<_ContentSection> sections;
  const _CategoryContent({required this.sections});
}

class _ContentSection {
  final String title;
  final List<_ContentItem> items;
  const _ContentSection({required this.title, required this.items});
}

class _ContentItem {
  final String label;
  final String image;
  const _ContentItem({required this.label, required this.image});
}