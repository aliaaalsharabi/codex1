import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

const Color _primary = Color(0xFF429EBD);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ نفس الـ collection في cart_vm
  CollectionReference get _cartRef => _firestore.collection('carts');

  Future<void> _removeFromCart(String cartId) async {
    await _cartRef.doc(cartId).delete();
  }

  Future<void> _updateQuantity(String cartId, int newQty) async {
    if (newQty < 1) {
      await _removeFromCart(cartId);
    } else {
      await _cartRef.doc(cartId).update({'quantity': newQty});
    }
  }

  Future<void> _clearCart(String userId) async {
    final batch = _firestore.batch();
    final snap = await _cartRef.where('userId', isEqualTo: userId).get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';
    return Provider.of<AppwriteStorageService>(context, listen: false)
        .getImageUrl(imageId);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final d = double.tryParse(price.toString()) ?? 0;
    return d == d.truncateToDouble() ? d.toInt().toString() : d.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<Theme_Vm>().isDarkMode;
    final loc    = context.watch<Language_Vm>().localization;
    final userId = _auth.currentUser?.uid ?? '';
    final Color bg     = isDark ? const Color(0xFF121212) : const Color(0xFFF5FAFD);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,

      // ===== AppBar — نفس ستايل باقي الشاشات =====
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          loc.appName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              loc.cartTitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _cartRef
            .where('userId', isEqualTo: userId)
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        size: 48, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(loc.errorOccurred,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      )),
                ],
              ),
            );
          }

          final cartDocs = snapshot.data?.docs ?? [];

          // ===== Empty Cart =====
          if (cartDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart_outlined,
                        size: 56,
                        color: isDark ? Colors.white38 : Colors.grey.shade400),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.emptyCart ?? 'السلة فارغة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.emptyCartSub ?? 'أضف منتجات من المتجر',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          // حساب المجموع
          double total = 0;
          for (final doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            total += ((data['price'] ?? 0) as num) *
                ((data['quantity'] ?? 1) as num);
          }

          return Column(
            children: [

              // ===== قائمة المنتجات =====
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final doc  = cartDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final imageUrl = _getImageUrl(data['imageId']);
                    final qty = (data['quantity'] ?? 1) as int;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [

                            // ===== صورة المنتج =====
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 72,
                                height: 72,
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFEAF4F9),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.image_not_supported_outlined,
                                    color: _primary.withOpacity(0.4),
                                    size: 28,
                                  ),
                                )
                                    : Icon(
                                  Icons.shopping_bag_outlined,
                                  color: _primary.withOpacity(0.4),
                                  size: 28,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ===== التفاصيل =====
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['productName'] ?? data['name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A2E3B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatPrice(data['price'])} ${loc.currency}',
                                    style: const TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // ===== الكمية =====
                                  Row(
                                    children: [
                                      _QtyButton(
                                        icon: Icons.remove_rounded,
                                        onTap: () => _updateQuantity(doc.id, qty - 1),
                                        color: Colors.grey.shade400,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          '$qty',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: Icons.add_rounded,
                                        onTap: () =>
                                            _updateQuantity(doc.id, qty + 1),
                                        color: _primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ===== حذف =====
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 22),
                              onPressed: () => _confirmDelete(context, doc.id, loc),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===== Summary + Checkout =====
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // المجموع
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.total,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(total == total.truncateToDouble() ? 0 : 1)} ${loc.currency}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A2E3B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // زر الدفع
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // منطق الدفع
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${loc.checkout} (${cartDocs.length})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ تأكيد الحذف
  void _confirmDelete(BuildContext context, String cartId, dynamic loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.confirmDelete ?? 'حذف المنتج'),
        content: Text(loc.confirmDeleteMsg ?? 'هل تريد حذف هذا المنتج من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel ?? 'إلغاء',
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromCart(cartId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(loc.delete ?? 'حذف',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ===== Qty Button =====
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}