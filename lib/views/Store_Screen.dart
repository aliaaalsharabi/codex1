import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/views/Product_details.dart';
import 'package:codex_firebase/views/cart_screen.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<dynamic>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final connectivity = Provider.of<ConnectivityService>(context, listen: false);
    _isConnected = connectivity.isConnected;
    if (_isConnected) {
      _productsFuture = context.read<Prodect_Vm>().fetchAllProducts();
    }
  }

  void _retryLoad() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final connectivity = Provider.of<ConnectivityService>(context);
    final primaryBlue = const Color(0xFF5DB1DF);

    // مراقبة تغيير حالة الإنترنت
    if (connectivity.isConnected != _isConnected) {
      _isConnected = connectivity.isConnected;
      if (_isConnected) {
        _loadData();
      }
      setState(() {});
    }

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: TextField(
                  controller: _searchController,
                  enabled: _isConnected,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: isDark ? TColors.white : TColors.black),
                  decoration: InputDecoration(
                    hintText: _isConnected ? 'بحث عن قطعة' : 'لا يوجد اتصال بالإنترنت',
                    hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                    prefixIcon: Icon(Icons.search, color: primaryBlue),
                    filled: true,
                    fillColor: isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: !_isConnected
                    ? const NoInternetWidget()
                    : FutureBuilder<List<dynamic>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF5DB1DF)));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حدث خطأ: ${snapshot.error}',
                              style: TextStyle(color: isDark ? TColors.white : TColors.black),
                            ),
                            const SizedBox(height: TSizes.md),
                            ElevatedButton(
                              onPressed: _retryLoad,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد منتجات حالياً',
                          style: TextStyle(color: isDark ? TColors.grey : Colors.black54),
                        ),
                      );
                    }

                    final products = snapshot.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: TSizes.sm,
                        mainAxisSpacing: TSizes.sm,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(productId: product.id),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA),
                              borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
                              border: isDark ? Border.all(color: Colors.white10) : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.image != null)
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(TSizes.cardRaduisMd)),
                                      child: Image.network(
                                        product.image!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, color: TColors.grey),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(TSizes.sm),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? TColors.white : TColors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.price} ر.س',
                                        style: TextStyle(
                                          color: isDark ? TColors.accent : const Color(0xFF429EBD),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'cart_fab',
              backgroundColor: primaryBlue,
              onPressed: _isConnected
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              }
                  : null,
              child: const Icon(Icons.shopping_cart, color: TColors.white),
            ),
          ),
        ],
      ),
    );
  }
}