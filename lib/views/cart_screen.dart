import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _removeFromCart(String cartId) async {
    await _firestore.collection('cart').doc(cartId).delete();
  }

  Future<void> _updateQuantity(String cartId, int newQuantity) async {
    if (newQuantity < 1) return;
    await _firestore.collection('cart').doc(cartId).update({'quantity': newQuantity});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final userId = _auth.currentUser?.uid ?? '';
    final primaryBlue = const Color(0xFF5DB1DF);
    final cardColor = isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,

      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text('CODEX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.person_outline, color: Colors.white),
        actions: [
          // ✅ تم تعديل أيقونة البيت لتصبح زر يرجعك للقائمة الرئيسية
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              // يرجعك للخلف (القائمة الرئيسية إذا كانت هي الواجهة السابقة)
              Navigator.pop(context);
              // أو يمكنك استخدام Navigator.pushReplacement إذا أردتِ الانتقال لواجهة محددة
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').where('userId', isEqualTo: userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ'));
          }
          final cartItems = snapshot.data!.docs;

          double total = 0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }

          return Column(
            children: [
              const SizedBox(height: 10),
              Text('سلة المشتريات', style: TextStyle(fontSize: 20, color: primaryBlue, fontWeight: FontWeight.w500)),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final data = item.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: primaryBlue, size: 24),
                          const SizedBox(width: 10),

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: data['image'] != null
                                ? Image.network(data['image'], width: 50, height: 50, fit: BoxFit.cover)
                                : Icon(Icons.memory, color: primaryBlue, size: 40),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(data['name'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                                Text('السعر: ${data['price']} ريال',
                                    style: TextStyle(color: primaryBlue, fontSize: 14)),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                                      onPressed: () => _updateQuantity(item.id, (data['quantity'] ?? 1) - 1),
                                    ),
                                    Text('${data['quantity'] ?? 1}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline, color: primaryBlue, size: 22),
                                      onPressed: () => _updateQuantity(item.id, (data['quantity'] ?? 1) + 1),
                                    ),
                                    const SizedBox(width: 20),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                      onPressed: () => _removeFromCart(item.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // هنا يمكنك إضافة منطق الدفع
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text('الدفع (${cartItems.length})', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),

                    Row(
                      children: [
                        Text('${total.toStringAsFixed(1)} ريال',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        const SizedBox(width: 15),
                        const Text('الكل', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(width: 5),
                        const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
                      ],
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
}