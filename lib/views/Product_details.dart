import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/product_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        backgroundColor: const Color(0xFF5DB1DF),
        foregroundColor: TColors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('حدث خطأ: $_error', style: const TextStyle(color: TColors.error)))
          : _product == null
          ? const Center(child: Text('المنتج غير موجود'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_product!['image'] != null)
              Image.network(
                _product!['image'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: TColors.grey,
                    child: const Icon(Icons.broken_image, size: 80),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!['name'] ?? '',
                    style: const TextStyle(
                      fontSize: TSizes.fontSizeLg + 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    '${_product!['price']?.toString() ?? '0'} ر.س',
                    style: const TextStyle(
                      fontSize: TSizes.fontSizeLg,
                      color: const Color(0xFF429EBD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.md),
                  const Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: TSizes.fontSizeMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    _product!['description'] ?? 'لا يوجد وصف لهذا المنتج',
                    style: const TextStyle(
                      fontSize: TSizes.fontSizeSm,
                      color: TColors.grey,
                    ),
                  ),
                  const SizedBox(height: TSizes.md),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: TColors.grey),
                      const SizedBox(width: TSizes.xs),
                      Text(
                        _product!['category'] ?? 'غير محدد',
                        style: const TextStyle(
                          fontSize: TSizes.fontSizeSm,
                          color: TColors.grey,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.inventory, size: 16, color: TColors.grey),
                      const SizedBox(width: TSizes.xs),
                      Text(
                        'الكمية: ${_product!['stockQuantity'] ?? 0}',
                        style: const TextStyle(
                          fontSize: TSizes.fontSizeSm,
                          color: TColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    height: TSizes.buttonHeight + 37,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DB1DF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إضافة المنتج إلى السلة'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        'إضافة إلى السلة',
                        style: TextStyle(
                          fontSize: TSizes.fontSizeMd,
                          color: TColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}