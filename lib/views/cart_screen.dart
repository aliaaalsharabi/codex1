import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState
    extends State<CartScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ================= REMOVE =================

  Future<void> _removeFromCart(
      String cartId) async {
    await _firestore
        .collection('cart')
        .doc(cartId)
        .delete();
  }

  // ================= UPDATE QUANTITY =================

  Future<void> _updateQuantity(
      String cartId,
      int newQuantity,
      ) async {
    if (newQuantity < 1) return;

    await _firestore
        .collection('cart')
        .doc(cartId)
        .update({
      'quantity': newQuantity,
    });
  }

  // ================= GET IMAGE =================

  String _getImageUrl(
      String? imageId) {
    if (imageId == null ||
        imageId.isEmpty) {
      return '';
    }

    final storageService =
    Provider.of<
        AppwriteStorageService>(
      context,
      listen: false,
    );

    return storageService
        .getImageUrl(imageId);
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context)
            .isDarkMode;

    final userId =
        _auth.currentUser?.uid ?? '';

    const primaryBlue =
    Color(0xFF5DB1DF);

    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F9FC);

    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return Scaffold(
      backgroundColor:
      backgroundColor,

      // ================= APP BAR =================

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
        Colors.transparent,

        flexibleSpace: Container(
          decoration:
          const BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                Color(0xFF5DB1DF),
                Color(0xFF7CCEF6),
              ],

              begin:
              Alignment.topRight,

              end:
              Alignment.bottomLeft,
            ),
          ),
        ),

        title: const Text(
          'سلة المشتريات',

          style: TextStyle(
            color: Colors.white,
            fontWeight:
            FontWeight.bold,
            fontSize: 22,
          ),
        ),

        leading: Container(
          margin:
          const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color:
            Colors.white24,
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),

          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
          ),
        ),

        actions: [
          Container(
            margin:
            const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color:
              Colors.white24,
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),

            child: IconButton(
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.white,
              ),

              onPressed: () {
                Navigator.pop(
                    context);
              },
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ================= BODY =================

      body:
      StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cart')
            .where(
          'userId',
          isEqualTo: userId,
        )
            .snapshots(),

        builder: (
            context,
            snapshot,
            ) {

          // ================= LOADING =================

          if (snapshot
              .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                primaryBlue,
              ),
            );
          }

          // ================= ERROR =================

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ',

                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            );
          }

          final cartItems =
              snapshot.data!.docs;

          // ================= TOTAL =================

          double total = 0;

          for (var item in cartItems) {
            final data =
            item.data()
            as Map<String,
                dynamic>;

            total +=
                (data['price'] ?? 0) *
                    (data['quantity'] ??
                        1);
          }

          // ================= EMPTY =================

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [

                  Container(
                    padding:
                    const EdgeInsets
                        .all(28),

                    decoration:
                    BoxDecoration(
                      shape:
                      BoxShape.circle,
                      color: isDark
                          ? Colors.white10
                          : Colors.white,

                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                            0.05,
                          ),
                          blurRadius:
                          15,
                        ),
                      ],
                    ),

                    child: Icon(
                      Icons
                          .shopping_cart_outlined,
                      size: 70,
                      color:
                      primaryBlue,
                    ),
                  ),

                  const SizedBox(
                      height: 24),

                  Text(
                    'السلة فارغة',

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    'قم بإضافة منتجات إلى السلة',

                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? Colors.white60
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ================= MAIN UI =================

          return Column(
            children: [

              const SizedBox(
                  height: 18),

              // ================= HEADER =================

              Padding(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  children: [

                    Text(
                      'منتجاتك',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight
                            .bold,
                        color: isDark
                            ? Colors
                            .white
                            : Colors
                            .black87,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        primaryBlue
                            .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: Text(
                        '${cartItems.length} عنصر',

                        style:
                        const TextStyle(
                          color:
                          primaryBlue,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 12),

              // ================= LIST =================

              Expanded(
                child:
                ListView.builder(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),

                  itemCount:
                  cartItems.length,

                  itemBuilder: (
                      context,
                      index,
                      ) {
                    final item =
                    cartItems[index];

                    final data =
                    item.data()
                    as Map<
                        String,
                        dynamic>;

                    final imageUrl =
                    _getImageUrl(
                      data['imageId'],
                    );

                    return Container(
                      margin:
                      const EdgeInsets
                          .only(
                        bottom: 18,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        cardColor,

                        borderRadius:
                        BorderRadius.circular(
                          24,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.05,
                            ),
                            blurRadius:
                            15,
                            offset:
                            const Offset(
                              0,
                              6,
                            ),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding:
                        const EdgeInsets
                            .all(
                          14,
                        ),

                        child: Row(
                          children: [

                            // ================= IMAGE =================

                            Container(
                              width: 90,
                              height: 90,

                              decoration:
                              BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(
                                  20,
                                ),

                                gradient:
                                LinearGradient(
                                  colors: [
                                    primaryBlue
                                        .withOpacity(
                                      0.12,
                                    ),
                                    primaryBlue
                                        .withOpacity(
                                      0.05,
                                    ),
                                  ],
                                ),
                              ),

                              child:
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(
                                  20,
                                ),

                                child:
                                imageUrl
                                    .isNotEmpty
                                    ? Image
                                    .network(
                                  imageUrl,
                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return Icon(
                                      Icons
                                          .broken_image_outlined,
                                      color:
                                      primaryBlue,
                                      size:
                                      45,
                                    );
                                  },
                                )
                                    : Icon(
                                  Icons
                                      .memory_rounded,
                                  color:
                                  primaryBlue,
                                  size:
                                  45,
                                ),
                              ),
                            ),

                            const SizedBox(
                                width:
                                16),

                            // ================= DETAILS =================

                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    data['name'] ??
                                        '',

                                    maxLines:
                                    1,

                                    overflow:
                                    TextOverflow.ellipsis,

                                    style:
                                    TextStyle(
                                      fontSize:
                                      18,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                      8),

                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal:
                                      12,
                                      vertical:
                                      6,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color:
                                      primaryBlue.withOpacity(
                                        0.1,
                                      ),

                                      borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                    ),

                                    child:
                                    Text(
                                      '${data['price']} ريال',

                                      style:
                                      const TextStyle(
                                        color:
                                        primaryBlue,
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize:
                                        14,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                      14),

                                  // ================= ACTIONS =================

                                  Row(
                                    children: [

                                      // ================= QUANTITY =================

                                      Container(
                                        decoration:
                                        BoxDecoration(
                                          color: isDark
                                              ? Colors.white10
                                              : const Color(
                                            0xFFF4F8FB,
                                          ),

                                          borderRadius:
                                          BorderRadius.circular(
                                            14,
                                          ),
                                        ),

                                        child:
                                        Row(
                                          children: [

                                            IconButton(
                                              icon:
                                              const Icon(
                                                Icons.remove,
                                                size:
                                                20,
                                              ),

                                              color:
                                              Colors.grey,

                                              onPressed:
                                                  () => _updateQuantity(
                                                item.id,
                                                (data['quantity'] ??
                                                    1) -
                                                    1,
                                              ),
                                            ),

                                            Text(
                                              '${data['quantity'] ?? 1}',

                                              style:
                                              TextStyle(
                                                fontSize:
                                                16,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),

                                            IconButton(
                                              icon:
                                              const Icon(
                                                Icons.add,
                                                size:
                                                20,
                                              ),

                                              color:
                                              primaryBlue,

                                              onPressed:
                                                  () => _updateQuantity(
                                                item.id,
                                                (data['quantity'] ??
                                                    1) +
                                                    1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Spacer(),

                                      // ================= DELETE =================

                                      Container(
                                        decoration:
                                        BoxDecoration(
                                          color: Colors
                                              .red
                                              .withOpacity(
                                            0.1,
                                          ),

                                          borderRadius:
                                          BorderRadius.circular(
                                            14,
                                          ),
                                        ),

                                        child:
                                        IconButton(
                                          icon:
                                          const Icon(
                                            Icons
                                                .delete_outline_rounded,
                                            color:
                                            Colors.red,
                                          ),

                                          onPressed:
                                              () =>
                                              _removeFromCart(
                                                item.id,
                                              ),
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
                  },
                ),
              ),

              // ================= BOTTOM =================

              Container(
                padding:
                const EdgeInsets
                    .all(22),

                decoration:
                BoxDecoration(
                  color: cardColor,

                  borderRadius:
                  const BorderRadius.only(
                    topLeft:
                    Radius.circular(
                      30,
                    ),
                    topRight:
                    Radius.circular(
                      30,
                    ),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.05,
                      ),
                      blurRadius: 15,
                      offset:
                      const Offset(
                        0,
                        -4,
                      ),
                    ),
                  ],
                ),

                child: SafeArea(
                  child: Row(
                    children: [

                      // ================= TOTAL =================

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              'الإجمالي',

                              style:
                              TextStyle(
                                fontSize:
                                15,
                                color: isDark
                                    ? Colors
                                    .white60
                                    : Colors
                                    .grey,
                              ),
                            ),

                            const SizedBox(
                                height:
                                6),

                            Text(
                              '${total.toStringAsFixed(1)} ريال',

                              style:
                              TextStyle(
                                fontSize:
                                24,
                                fontWeight:
                                FontWeight.bold,
                                color: isDark
                                    ? Colors
                                    .white
                                    : Colors
                                    .black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          width: 18),

                      // ================= CHECKOUT =================

                      Expanded(
                        child:
                        SizedBox(
                          height: 58,

                          child:
                          ElevatedButton(
                            onPressed:
                                () {
                              // منطق الدفع
                            },

                            style:
                            ElevatedButton
                                .styleFrom(
                              elevation:
                              0,

                              backgroundColor:
                              primaryBlue,

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),

                            child:
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                const Icon(
                                  Icons
                                      .shopping_bag_outlined,
                                  color:
                                  Colors.white,
                                ),

                                const SizedBox(
                                    width:
                                    8),

                                Text(
                                  'الدفع (${cartItems.length})',

                                  style:
                                  const TextStyle(
                                    fontSize:
                                    17,
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    Colors.white,
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
              ),
            ],
          );
        },
      ),
    );
  }
}