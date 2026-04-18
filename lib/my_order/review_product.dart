import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smm_power/smm_support/support.dart';

class ReviewStore {
  static List<Map<String, dynamic>> reviews = [];
}

const Color kPrimary = Color(0xFF4256D3);
const Color kGreen = Color(0xFF2E7D32);
const Color kRed = Color(0xFFD32F2F);
const Color kYellow = Color(0xFFFFCC00);

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────
class ReviewProductModel {
  final String productName;
  final String subtitle;
  final String imagePath;

  const ReviewProductModel({
    required this.productName,
    required this.subtitle,
    required this.imagePath,
  });
}

// ─────────────────────────────────────────
// REVIEW PRODUCT PAGE
// ─────────────────────────────────────────
class ReviewProductPage extends StatefulWidget {
  final ReviewProductModel product;

  const ReviewProductPage({
    super.key,
    required this.product,
  });

  @override
  State<ReviewProductPage> createState() => _ReviewProductPageState();
}

class _ReviewProductPageState extends State<ReviewProductPage> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedPhotos = [];
  XFile? _selectedVideo;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kPrimary),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (photo != null) {
                  setState(() => _selectedPhotos.add(photo));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: kPrimary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final List<XFile> photos = await _picker.pickMultiImage(
                  imageQuality: 80,
                );
                if (photos.isNotEmpty) {
                  setState(() => _selectedPhotos.addAll(photos));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PICK VIDEO
  // ─────────────────────────────────────────
  Future<void> _pickVideo() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam, color: kPrimary),
              title: const Text('Record Video'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? video = await _picker.pickVideo(
                  source: ImageSource.camera,
                  maxDuration: const Duration(minutes: 2),
                );
                if (video != null) {
                  setState(() => _selectedVideo = video);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: kPrimary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? video = await _picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (video != null) {
                  setState(() => _selectedVideo = video);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderText(),

            const SizedBox(height: 16),
            _buildProductCard(),

            const SizedBox(height: 18),
            _buildSectionLabel('Add Photo or Video'),

            const SizedBox(height: 10),
            _buildMediaButtons(),

            const SizedBox(height: 18),
            _buildSectionLabel('Overall rating'),

            const SizedBox(height: 12),
            _buildStarRating(),

            const SizedBox(height: 20),
            _buildReviewTextField(),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // ── BOTTOM AREA: Floating Help + Submit Button ──
      bottomNavigationBar: _buildSubmitButton(),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SmmSupportPage(),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECFB),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.support_agent,
                  color: kPrimary,
                  size: 18, // 👈 reduced
                ),
                SizedBox(height: 2),
                Text(
                  "Help",
                  style: TextStyle(
                    fontSize: 10, // 👈 very small to fit
                    color: kPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: kPrimary,
          size: 15,
        ),
      ),
      titleSpacing: 0,
      title: const Text(
        'Review Product',
        style: TextStyle(
          color: kPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
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

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Rate your product',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Share your experience with Solar Street Light 30W',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
            letterSpacing: 0,
          ),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.product.imagePath,
              width: 62,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 62,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFFAAAAAA),
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.product.subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF373737),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF000000),
      ),
    );
  }

  // ─────────────────────────────────────────
  // MEDIA BUTTONS (Photo / Video)
  // ─────────────────────────────────────────
  Widget _buildMediaButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BUTTONS ROW ──
        Row(
          children: [
            // Photo Button
            Expanded(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/my_order/photo.gif',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.photo_camera_outlined,
                          color: kPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Video Button
            Expanded(
              child: GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/my_order/video.gif',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.videocam_outlined,
                          color: kPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Video',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── SELECTED PHOTOS PREVIEW ──
        if (_selectedPhotos.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedPhotos[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 2,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedPhotos.removeAt(index));
                        },
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],

        // ── SELECTED VIDEO PREVIEW ──
        if (_selectedVideo != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: kPrimary,
                    size: 36,
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedVideo = null),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────
  // STAR RATING
  // ─────────────────────────────────────────
  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final bool isFilled = index < _selectedRating;
        return GestureDetector(
          onTap: () => setState(() => _selectedRating = index + 1),
          child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF4256D3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 18,
              color: isFilled ? kYellow : const Color(0xFFCCCCCC),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────
  // REVIEW TEXT FIELD
  // ─────────────────────────────────────────
  Widget _buildReviewTextField() {
    return Container(
      width: 320,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDADADA)),
      ),
      child: TextField(
        controller: _reviewController,
        maxLines: 6,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF000000),
        ),
        decoration: const InputDecoration(
          hintText: 'How did the product perform?',
          hintStyle: TextStyle(
            fontSize: 12,
            color: Color(0xFFDADADA),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.all(12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_selectedRating == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a rating'),
                  backgroundColor: kPrimary,
                ),
              );
              return;
            }

            ReviewStore.reviews.insert(0, {
              'rating': _selectedRating,
              'review': _reviewController.text,
              'name': 'You',
              'date': 'Just now',
            });

            Navigator.pop(context, true);
          },
          child: const Text(
            'Submit the Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}