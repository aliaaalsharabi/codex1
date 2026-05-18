import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/views/Product_details.dart';
import 'package:codex_firebase/views/cart_screen.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/model/product.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<Product>> _productsFuture;

  final TextEditingController _searchController =
  TextEditingController();

  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final connectivity =
    Provider.of<ConnectivityService>(
      context,
      listen: false,
    );

    _isConnected = connectivity.isConnected;

    if (_isConnected) {
      _productsFuture =
          context.read<Prodect_Vm>().fetchAllProducts();
    }
  }

  void _retryLoad() {
    setState(() {
      _loadData();
    });
  }

  // ✅ جلب رابط الصورة من Appwrite
  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';

    final storageService =
    Provider.of<AppwriteStorageService>(
      context,
      listen: false,
    );

    return storageService.getImageUrl(imageId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context).isDarkMode;

    final connectivity =
    Provider.of<ConnectivityService>(context);

    const primaryBlue = Color(0xFF5DB1DF);

    // تحديث حالة الإنترنت
    if (connectivity.isConnected != _isConnected) {
      _isConnected = connectivity.isConnected;

      if (_isConnected) {
        _loadData();
      }

      setState(() {});
    }

    return Scaffold(
      backgroundColor:
      isDark ? TColors.dark : const Color(0xFFF7FAFC),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cart_fab',
        backgroundColor: primaryBlue,
        elevation: 8,
        onPressed: _isConnected
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const CartScreen(),
            ),
          );
        }
            : null,
        icon: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
        ),
        label: const Text(
          'السلة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                24,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF5DB1DF),
                    Color(0xFF429EBD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    'المتجر التقني',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'اكتشف أفضل القطع والأدوات التقنية',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SEARCH
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      enabled: _isConnected,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isDark
                            ? TColors.black
                            : TColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: _isConnected
                            ? 'ابحث عن قطعة تقنية...'
                            : 'لا يوجد اتصال بالإنترنت',

                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),

                        prefixIcon: const Icon(
                          Icons.search,
                          color: primaryBlue,
                        ),

                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                            primaryBlue.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: primaryBlue,
                            size: 20,
                          ),
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                          borderSide:
                          BorderSide.none,
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                          borderSide:
                          const BorderSide(
                            color: primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // BODY
            Expanded(
              child: !_isConnected
                  ? const NoInternetWidget()
                  : FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder:
                    (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                      CircularProgressIndicator(
                        color: primaryBlue,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                            20),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 70,
                              color: isDark
                                  ? TColors.grey
                                  : Colors.grey,
                            ),

                            const SizedBox(
                                height: 16),

                            Text(
                              'حدث خطأ أثناء تحميل المنتجات',
                              style: TextStyle(
                                fontSize: 18,
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
                                height: 10),

                            Text(
                              '${snapshot.error}',
                              textAlign:
                              TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? TColors
                                    .grey
                                    : Colors.grey,
                              ),
                            ),

                            const SizedBox(
                                height: 20),

                            ElevatedButton(
                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                primaryBlue,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      14),
                                ),
                              ),
                              onPressed:
                              _retryLoad,
                              child: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(
                                  color: Colors
                                      .white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons
                                .shopping_bag_outlined,
                            size: 80,
                            color: isDark
                                ? TColors.grey
                                : Colors.grey,
                          ),

                          const SizedBox(
                              height: 20),

                          Text(
                            'لا توجد منتجات حالياً',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                              color: isDark
                                  ? TColors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final products =
                  snapshot.data!;

                  return GridView.builder(
                    padding:
                    const EdgeInsets.all(
                        16),

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),

                    itemCount:
                    products.length,

                    itemBuilder:
                        (context, index) {
                      final product =
                      products[index];

                      final imageUrl =
                      _getImageUrl(
                          product.imageId);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  ProductDetailsScreen(
                                    productId:
                                    product.id,
                                  ),
                            ),
                          );
                        },

                        child: AnimatedContainer(
                          duration:
                          const Duration(
                              milliseconds:
                              250),

                          decoration:
                          BoxDecoration(
                            color: isDark
                                ? TColors
                                .darkerGrey
                                : Colors.white,

                            borderRadius:
                            BorderRadius
                                .circular(
                                24),

                            border: isDark
                                ? Border.all(
                              color: Colors
                                  .white10,
                            )
                                : null,

                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                    0.05),
                                blurRadius:
                                14,
                                offset:
                                const Offset(
                                    0, 6),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [
                              // IMAGE
                              Expanded(
                                flex: 6,
                                child: Container(
                                  decoration:
                                  BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.vertical(
                                      top: Radius
                                          .circular(
                                          24),
                                    ),
                                    color: isDark
                                        ? Colors
                                        .black26
                                        : const Color(
                                        0xFFF5F7FA),
                                  ),

                                  child: imageUrl
                                      .isNotEmpty
                                      ? ClipRRect(
                                    borderRadius:
                                    const BorderRadius.vertical(
                                      top: Radius.circular(
                                          24),
                                    ),
                                    child:
                                    Image.network(
                                      imageUrl,
                                      width: double
                                          .infinity,
                                      fit: BoxFit
                                          .cover,

                                      errorBuilder:
                                          (
                                          context,
                                          error,
                                          stackTrace,
                                          ) {
                                        return Center(
                                          child:
                                          Icon(
                                            Icons.broken_image_outlined,
                                            size:
                                            50,
                                            color: isDark
                                                ? TColors.grey
                                                : Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                      : Center(
                                    child:
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size:
                                          50,
                                          color: isDark
                                              ? TColors.grey
                                              : Colors.grey,
                                        ),
                                        const SizedBox(
                                            height:
                                            8),
                                        Text(
                                          'لا توجد صورة',
                                          style:
                                          TextStyle(
                                            color: isDark
                                                ? TColors.grey
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // INFO
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(
                                      14),
                                  child:
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product
                                            .name,
                                        maxLines:
                                        2,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style:
                                        TextStyle(
                                          fontSize:
                                          15,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: isDark
                                              ? TColors.white
                                              : Colors.black87,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Expanded(
                                            child:
                                            Text(
                                              '${product.price} ر.س',
                                              style:
                                              const TextStyle(
                                                color:
                                                primaryBlue,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                16,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            padding:
                                            const EdgeInsets.all(
                                                8),
                                            decoration:
                                            BoxDecoration(
                                              color:
                                              primaryBlue,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                            ),
                                            child:
                                            const Icon(
                                              Icons
                                                  .add_shopping_cart,
                                              size:
                                              18,
                                              color:
                                              Colors.white,
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}