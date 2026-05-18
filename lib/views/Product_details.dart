import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product =
      await Provider.of<Prodect_Vm>(
        context,
        listen: false,
      ).getProductById(widget.productId);

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

  // ✅ جلب رابط الصورة من Appwrite
  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';

    final storageService = Provider.of<AppwriteStorageService>(
      context,
      listen: false,
    );

    return storageService.getImageUrl(imageId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context).isDarkMode;

    final bgColor =
    isDark ? TColors.dark : const Color(0xFFF7FBFE);

    final cardColor =
    isDark ? TColors.darkerGrey : Colors.white;

    final primaryBlue = const Color(0xFF5DB1DF);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: TColors.white,
        title: const Text(
          'تفاصيل المنتج',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(
            TSizes.md,
          ),
          child: Text(
            'حدث خطأ: $_error',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? TColors.white
                  : TColors.error,
              fontSize: TSizes.fontSizeMd,
            ),
          ),
        ),
      )

          : _product == null
          ? Center(
        child: Text(
          'المنتج غير موجود',
          style: TextStyle(
            color: isDark
                ? TColors.white
                : TColors.black,
            fontSize: TSizes.fontSizeLg,
          ),
        ),
      )

          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            _buildProductImage(
              isDark,
              primaryBlue,
            ),

            Transform.translate(
              offset: const Offset(0, -25),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  TSizes.lg,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                  const BorderRadius.only(
                    topLeft: Radius.circular(
                      35,
                    ),
                    topRight: Radius.circular(
                      35,
                    ),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج + السعر
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                _product!['name'] ??
                                    '',
                                style: TextStyle(
                                  fontSize:
                                  TSizes
                                      .fontSizeLg +
                                      6,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  color: isDark
                                      ? TColors
                                      .white
                                      : TColors
                                      .black,
                                ),
                              ),

                              const SizedBox(
                                height:
                                TSizes.xs,
                              ),

                              Text(
                                '${_product!['price']?.toString() ?? '0'} ر.س',
                                style:
                                TextStyle(
                                  fontSize:
                                  TSizes
                                      .fontSizeLg +
                                      2,
                                  color:
                                  primaryBlue,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                          const EdgeInsets
                              .all(12),
                          decoration:
                          BoxDecoration(
                            color: primaryBlue
                                .withOpacity(
                              0.12,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),
                          child: Icon(
                            Icons
                                .shopping_bag_outlined,
                            color:
                            primaryBlue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                      TSizes.spaceBtwSections,
                    ),

                    // الوصف
                    _buildSectionTitle(
                      'الوصف',
                      isDark,
                    ),

                    const SizedBox(
                      height: TSizes.sm,
                    ),

                    Text(
                      _product![
                      'description'] ??
                          'لا يوجد وصف لهذا المنتج',
                      style: TextStyle(
                        fontSize:
                        TSizes.fontSizeMd,
                        height: 1.8,
                        color: isDark
                            ? TColors.grey
                            : TColors
                            .darkGrey,
                      ),
                    ),

                    const SizedBox(
                      height:
                      TSizes.spaceBtwSections,
                    ),

                    // المعلومات
                    Row(
                      children: [
                        Expanded(
                          child:
                          _buildInfoCard(
                            title:
                            'التصنيف',
                            value:
                            _product![
                            'category'] ??
                                'غير محدد',
                            icon:
                            Icons.category,
                            isDark:
                            isDark,
                            primaryBlue:
                            primaryBlue,
                          ),
                        ),

                        const SizedBox(
                          width:
                          TSizes.sm,
                        ),

                        Expanded(
                          child:
                          _buildInfoCard(
                            title:
                            'الكمية',
                            value:
                            '${_product!['stockQuantity'] ?? 0}',
                            icon:
                            Icons.inventory_2_outlined,
                            isDark:
                            isDark,
                            primaryBlue:
                            primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 35,
                    ),

                    // زر الإضافة للسلة
                    SizedBox(
                      width:
                      double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style:
                        ElevatedButton
                            .styleFrom(
                          elevation: 6,
                          backgroundColor:
                          primaryBlue,
                          shadowColor:
                          primaryBlue
                              .withOpacity(
                            0.4,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              20,
                            ),
                          ),
                        ),

                        onPressed: () {
                          ScaffoldMessenger.of(
                              context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم إضافة المنتج إلى السلة',
                              ),
                              backgroundColor:
                              Colors
                                  .green,
                            ),
                          );
                        },

                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: const [
                            Icon(
                              Icons
                                  .shopping_cart_checkout,
                              color: Colors
                                  .white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'إضافة إلى السلة',
                              style:
                              TextStyle(
                                fontSize:
                                18,
                                color: Colors
                                    .white,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ صورة المنتج
  Widget _buildProductImage(
      bool isDark,
      Color primaryBlue,
      ) {
    final imageId = _product!['imageId'];
    final imageUrl = _getImageUrl(imageId);

    if (imageUrl.isNotEmpty) {
      return Stack(
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,

              errorBuilder:
                  (context, error, stackTrace) {
                return _buildImageError(isDark);
              },
            ),
          ),

          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.transparent,
                  Colors.black.withOpacity(0.25),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _buildNoImage(isDark);
  }

  // ✅ لا توجد صورة
  Widget _buildNoImage(bool isDark) {
    return Container(
      height: 320,
      width: double.infinity,
      color: isDark
          ? Colors.black26
          : const Color(0xFFEAF7FD),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 90,
            color: isDark
                ? TColors.grey
                : Colors.grey.shade500,
          ),

          const SizedBox(height: TSizes.sm),

          Text(
            'لا توجد صورة للمنتج',
            style: TextStyle(
              fontSize: TSizes.fontSizeMd,
              color: isDark
                  ? TColors.grey
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ خطأ الصورة
  Widget _buildImageError(bool isDark) {
    return Container(
      height: 320,
      color:
      isDark ? Colors.black26 : Colors.grey.shade200,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 90,
            color: isDark
                ? TColors.grey
                : Colors.grey.shade500,
          ),

          const SizedBox(height: TSizes.sm),

          Text(
            'فشل تحميل الصورة',
            style: TextStyle(
              color: isDark
                  ? TColors.grey
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ عنوان القسم
  Widget _buildSectionTitle(
      String title,
      bool isDark,
      ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: TSizes.fontSizeLg,
        fontWeight: FontWeight.bold,
        color:
        isDark ? TColors.white : TColors.black,
      ),
    );
  }

  // ✅ كروت المعلومات
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color primaryBlue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDark
            ? TColors.dark.withOpacity(0.4)
            : const Color(0xFFF5FAFD),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: primaryBlue.withOpacity(0.15),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: isDark
                  ? TColors.grey
                  : TColors.darkGrey,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: TSizes.fontSizeMd,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? TColors.white
                  : TColors.black,
            ),
          ),
        ],
      ),
    );
  }
}