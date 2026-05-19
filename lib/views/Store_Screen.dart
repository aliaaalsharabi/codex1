import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/modelview/cart_vm.dart';
import 'package:codex_firebase/views/Product_details.dart';
import 'package:codex_firebase/views/cart_screen.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/model/product.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

const Color _primary = Color(0xFF429EBD);

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Future<List<Product>> _productsFuture = Future.value([]);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Product> _allProducts      = [];
  List<Product> _filteredProducts = [];
  bool _isConnected   = true;
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _scrollController.addListener(() {
      final shouldCollapse = _scrollController.offset > 60;
      if (shouldCollapse == _isFabExtended) {
        setState(() => _isFabExtended = !shouldCollapse);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final connectivity =
    Provider.of<ConnectivityService>(context, listen: false);
    _isConnected = connectivity.isConnected;
    if (!_isConnected) return;

    setState(() {
      _productsFuture = context
          .read<Prodect_Vm>()
          .fetchAllProducts()
          .then((products) {
        _allProducts      = products;
        _filteredProducts = products;
        return products;
      });
    });
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredProducts = query.isEmpty
          ? _allProducts
          : _allProducts
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    });
  }

  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';
    return Provider.of<AppwriteStorageService>(context, listen: false)
        .getImageUrl(imageId);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final d = double.tryParse(price.toString()) ?? 0;
    return d == d.truncateToDouble()
        ? d.toInt().toString()
        : d.toString();
  }

  Future<void> _addToCart(Product product) async {
    try {
      await Provider.of<Cart_Vm>(context, listen: false).addToCart(product);
      if (!mounted) return;
      final loc = Provider.of<Language_Vm>(context, listen: false).localization;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${product.name} ${loc.addedToCart}'),
        backgroundColor: _primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('فشل الإضافة للسلة'),
        backgroundColor: TColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark       = context.watch<Theme_Vm>().isDarkMode;
    final connectivity = context.watch<ConnectivityService>();
    final loc          = context.watch<Language_Vm>().localization;
    final Color bg     = isDark ? const Color(0xFF121212) : const Color(0xFFF5FAFD);

    if (connectivity.isConnected != _isConnected) {
      _isConnected = connectivity.isConnected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadData();
      });
    }

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [

          // ===== Search Bar =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                enabled: _isConnected,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: _isConnected
                      ? loc.searchProduct
                      : loc.noInternet,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _primary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: isDark
                            ? Colors.white38
                            : Colors.grey.shade400,
                        size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch();
                    },
                  )
                      : null,
                  filled: false,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    const BorderSide(color: _primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // ===== Body =====
          Expanded(
            child: !_isConnected
                ? const NoInternetWidget()
                : FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {

                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Text(loc.errorOccurred,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            )),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh_rounded,
                              size: 18),
                          label: Text(loc.retry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Empty
                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _searchController.text.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.shopping_bag_outlined,
                            size: 48,
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? loc.noResults
                              : loc.noProducts,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white60
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ===== Grid =====
                return RefreshIndicator(
                  color: _primary,
                  onRefresh: () async => _loadData(),
                  child: GridView.builder(
                    controller: _scrollController, // ✅ FAB scroll
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final imageUrl = _getImageUrl(product.imageId);
                      return _ProductCard(
                        product: product,
                        imageUrl: imageUrl,
                        isDark: isDark,
                        loc: loc,
                        formattedPrice: _formatPrice(product.price),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(
                                productId: product.id),
                          ),
                        ),
                        onAddToCart: () => _addToCart(product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ===== FAB — يتقلص عند الـ scroll ✅ =====
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isFabExtended
            ? FloatingActionButton.extended(
          key: const ValueKey('extended'),
          heroTag: 'cart_fab',
          backgroundColor: _isConnected ? _primary : Colors.grey,
          elevation: 2,
          icon: const Icon(Icons.shopping_cart_rounded,
              color: Colors.white),
          label: Text(
            loc.cart,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isConnected
              ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CartScreen()))
              : null,
        )
            : FloatingActionButton(
          key: const ValueKey('collapsed'),
          heroTag: 'cart_fab',
          backgroundColor: _isConnected ? _primary : Colors.grey,
          elevation: 2,
          onPressed: _isConnected
              ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CartScreen()))
              : null,
          child: const Icon(Icons.shopping_cart_rounded,
              color: Colors.white),
        ),
      ),
    );
  }
}

// ===========================================
// ===== Product Card =====
// ===========================================
class _ProductCard extends StatelessWidget {
  final Product product;
  final String imageUrl;
  final bool isDark;
  final dynamic loc;
  final String formattedPrice;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.imageUrl,
    required this.isDark,
    required this.loc,
    required this.formattedPrice,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== الصورة =====
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: isDark
                          ? Colors.white10
                          : Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: _primary, strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
            ),

            // ===== التفاصيل =====
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A2E3B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$formattedPrice ${loc.sar}',
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      // ✅ زر إضافة للسلة
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
              : [const Color(0xFFDEEFF7), const Color(0xFFEAF4F9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 40,
              color: isDark
                  ? Colors.white24
                  : _primary.withOpacity(0.35)),
          const SizedBox(height: 6),
          Text(
            loc.noImage,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white24
                  : _primary.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}