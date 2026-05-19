import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/model/product.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/modelview/cart_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/language_vm.dart';
import 'package:codex_firebase/l10n/app_localization.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String? _error;

  static const Color _primaryBlue = Color(0xFF5DB1DF);

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await Provider.of<Prodect_Vm>(context, listen: false)
          .getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ✅ رابط الصورة — المفتاح 'image' في Firestore
  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';
    return Provider.of<AppwriteStorageService>(context, listen: false)
        .getImageUrl(imageId);
  }

  Future<void> _addToCart(AppLocalization loc) async {
    if (_product == null || _isAddingToCart) return;

    final stock = _product!['stockQuantity'] ?? 0;
    if (stock <= 0) {
      _showSnackBar(loc.outOfStock, Colors.orange);
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final product = Product(
        id: widget.productId,
        name: _product!['name'] ?? '',
        price: (_product!['price'] ?? 0).toDouble(),
        imageId: _product!['image'],              // ✅ 'image' مش 'imageId'
        description: _product!['description'],
        category: _product!['category'] ?? '',
        stockQuantity: stock,
        userId: _product!['userId'] ?? '',
        status: _product!['status'] ?? 'available',
      );

      await Provider.of<Cart_Vm>(context, listen: false).addToCart(product);
      if (mounted) _showSnackBar(loc.addedToCart, Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar('${loc.errorOccurred}: $e', TColors.error);
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;
    final bgColor = isDark ? TColors.dark : const Color(0xFFF7FBFE);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          loc.productDetails,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),

      bottomNavigationBar: _product == null ? null : _buildBottomBar(isDark, loc),

      body: _isLoading
          ? _buildShimmerLoading(isDark)
          : _error != null
          ? _buildError(isDark, loc)
          : _product == null
          ? _buildNotFound(isDark, loc)
          : _buildContent(isDark, loc),
    );
  }

  // ──────────────────────────────────────────
  // BODY
  // ──────────────────────────────────────────

  Widget _buildContent(bool isDark, AppLocalization loc) {
    final cardColor = isDark ? TColors.darkerGrey : Colors.white;
    final stock = _product!['stockQuantity'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(isDark, loc),

          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                TSizes.lg, TSizes.lg, TSizes.lg, 100,
              ),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج + badge الكمية
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product!['name'] ?? '',
                              style: TextStyle(
                                fontSize: TSizes.fontSizeLg + 6,
                                fontWeight: FontWeight.bold,
                                color: isDark ? TColors.white : TColors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: stock > 0
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stock > 0
                                    ? '${loc.available}: $stock'
                                    : loc.outOfStock,
                                style: TextStyle(
                                  fontSize: TSizes.fontSizeSm,
                                  fontWeight: FontWeight.w600,
                                  color: stock > 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: _primaryBlue,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  // الوصف
                  _buildSectionTitle(loc.description, isDark),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    _product!['description'] ?? loc.noDescription,
                    style: TextStyle(
                      fontSize: TSizes.fontSizeMd,
                      height: 1.8,
                      color: isDark ? TColors.grey : TColors.darkGrey,
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  // كروت المعلومات
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          title: loc.category,
                          value: _product!['category'] ?? loc.typeUnknown,
                          icon: Icons.category_outlined,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: TSizes.sm),
                      Expanded(
                        child: _buildInfoCard(
                          title: loc.quantity,
                          value: '$stock',
                          icon: Icons.inventory_2_outlined,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // BOTTOM BAR
  // ──────────────────────────────────────────

  Widget _buildBottomBar(bool isDark, AppLocalization loc) {
    final cardColor = isDark ? TColors.darkerGrey : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // السعر
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.price,
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm,
                    color: isDark ? TColors.grey : TColors.darkGrey,
                  ),
                ),
                Text(
                  '${_product!['price']?.toString() ?? '0'} ${loc.sar}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // زر إضافة للسلة
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: _primaryBlue,
                    shadowColor: _primaryBlue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isAddingToCart ? null : () => _addToCart(loc),
                  child: _isAddingToCart
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.addToCart,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // SHIMMER LOADING
  // ──────────────────────────────────────────

  Widget _buildShimmerLoading(bool isDark) {
    final shimmerColor =
    isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200;

    return Column(
      children: [
        Container(height: 320, color: shimmerColor),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              4,
                  (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: i == 0 ? 28 : 16,
                  width: i == 0 ? 200 : double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────

  Widget _buildProductImage(bool isDark, AppLocalization loc) {
    final imageUrl = _getImageUrl(_product!['image']); // ✅ 'image' مش 'imageId'

    return Stack(
      children: [
        SizedBox(
          height: 360,
          width: double.infinity,
          child: imageUrl.isNotEmpty
              ? Hero(
            tag: 'product_${widget.productId}',
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildImagePlaceholder(isDark, loc, broken: true),
            ),
          )
              : _buildImagePlaceholder(isDark, loc),
        ),
        Container(
          height: 360,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(
      bool isDark,
      AppLocalization loc, {
        bool broken = false,
      }) {
    return Container(
      height: 360,
      color: isDark ? Colors.black26 : const Color(0xFFEAF7FD),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            broken
                ? Icons.broken_image_outlined
                : Icons.image_not_supported_outlined,
            size: 90,
            color: isDark ? TColors.grey : Colors.grey.shade400,
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            broken ? loc.imageLoadFailed : loc.noProductImage,
            style: TextStyle(
              color: isDark ? TColors.grey : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: TSizes.fontSizeLg,
        fontWeight: FontWeight.bold,
        color: isDark ? TColors.white : TColors.black,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TColors.dark.withOpacity(0.4)
            : const Color(0xFFF5FAFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryBlue, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: isDark ? TColors.grey : TColors.darkGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: TSizes.fontSizeMd,
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.white : TColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark, AppLocalization loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: TColors.error),
            const SizedBox(height: TSizes.sm),
            Text(
              '${loc.errorOccurred}: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? TColors.white : TColors.error,
                fontSize: TSizes.fontSizeMd,
              ),
            ),
            const SizedBox(height: TSizes.md),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(bool isDark, AppLocalization loc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: isDark ? TColors.grey : Colors.grey.shade400,
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            loc.productNotFound,
            style: TextStyle(
              color: isDark ? TColors.white : TColors.black,
              fontSize: TSizes.fontSizeLg,
            ),
          ),
        ],
      ),
    );
  }
}