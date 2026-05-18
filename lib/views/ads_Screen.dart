import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/modelview/adv_job_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/views/Comments_Screen.dart';
import 'package:codex_firebase/model/advertisement_job.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  late Future<List<AdvertisementJob>> _jobsFuture;

  bool _isConnected = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ================= LOAD DATA =================

  void _loadData() {
    final connectivity =
    Provider.of<ConnectivityService>(
      context,
      listen: false,
    );

    _isConnected = connectivity.isConnected;

    if (_isConnected) {
      _jobsFuture = context
          .read<Advertisement_of_jop_Vm>()
          .getAllJobs();
    }
  }

  // ================= RETRY =================

  void _retryLoad() {
    setState(() {
      _loadData();
    });
  }

  // ================= REFRESH =================

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  // ================= LIKE =================

  Future<void> _toggleLike(
      AdvertisementJob job) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) return;

    final jobRef =
    _firestore.collection('jobs').doc(
      job.idJob,
    );

    final isLiked =
        job.likes?.contains(userId) ?? false;

    if (isLiked) {
      await jobRef.update({
        'likes':
        FieldValue.arrayRemove([userId]),
        'numberOfLike':
        FieldValue.increment(-1),
      });
    } else {
      await jobRef.update({
        'likes':
        FieldValue.arrayUnion([userId]),
        'numberOfLike':
        FieldValue.increment(1),
      });
    }

    _refreshData();
  }

  // ================= IMAGE URL =================

  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return '';
    }

    final storageService =
    Provider.of<AppwriteStorageService>(
      context,
      listen: false,
    );

    return storageService.getImageUrl(
      imageId,
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<Theme_Vm>(context)
            .isDarkMode;

    final connectivity =
    Provider.of<ConnectivityService>(
      context,
    );

    if (connectivity.isConnected !=
        _isConnected) {
      _isConnected =
          connectivity.isConnected;

      if (_isConnected) {
        _loadData();
      }

      setState(() {});
    }

    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ================= APP BAR =================

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,

        title: const Text(
          'إعلانات الوظائف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4FA8D8),
                Color(0xFF72C6EF),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: !_isConnected
          ? const NoInternetWidget()
          : FutureBuilder<List<AdvertisementJob>>(
        future: _jobsFuture,

        builder: (
            context,
            snapshot,
            ) {
          // ================= LOADING =================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(
                color: Color(0xFF4FA8D8),
              ),
            );
          }

          // ================= ERROR =================

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [

                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed:
                    _retryLoad,

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF4FA8D8,
                      ),
                    ),

                    child: const Text(
                      'إعادة المحاولة',
                    ),
                  ),
                ],
              ),
            );
          }

          // ================= EMPTY =================

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [

                  Icon(
                    Icons.work_off,
                    size: 70,
                    color: isDark
                        ? Colors.white54
                        : Colors.grey,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'لا توجد وظائف حالياً',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }

          // ================= DATA =================

          final jobs = snapshot.data!;

          return RefreshIndicator(
            color: const Color(
              0xFF4FA8D8,
            ),

            onRefresh: () async {
              _refreshData();
            },

            child: ListView.builder(
              padding:
              const EdgeInsets.all(18),

              itemCount: jobs.length,

              itemBuilder: (
                  context,
                  index,
                  ) {
                final job = jobs[index];

                final imageUrl =
                _getImageUrl(
                  job.imageId,
                );

                return Container(
                  margin:
                  const EdgeInsets.only(
                    bottom: 22,
                  ),

                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(
                        0xFF1C1C1C)
                        : Colors.white,

                    borderRadius:
                    BorderRadius
                        .circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.05,
                        ),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset:
                        const Offset(
                          0,
                          8,
                        ),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      // ================= IMAGE =================

                      ClipRRect(
                        borderRadius:
                        const BorderRadius.only(
                          topLeft:
                          Radius.circular(
                            28,
                          ),
                          topRight:
                          Radius.circular(
                            28,
                          ),
                        ),

                        child:
                        imageUrl.isNotEmpty
                            ? Stack(
                          children: [

                            Image.network(
                              imageUrl,
                              height:
                              220,
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
                                return Container(
                                  height:
                                  220,
                                  color: Colors
                                      .grey
                                      .shade300,
                                  child:
                                  const Icon(
                                    Icons
                                        .broken_image,
                                    size:
                                    60,
                                  ),
                                );
                              },
                            ),

                            Positioned(
                              top:
                              14,
                              right:
                              14,

                              child:
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
                                  job.isOpen
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                                ),

                                child:
                                Text(
                                  job.isOpen
                                      ? 'مفتوح'
                                      : 'مغلق',

                                  style:
                                  const TextStyle(
                                    color:
                                    Colors.white,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Container(
                          height: 220,
                          color: isDark
                              ? Colors
                              .black26
                              : Colors
                              .grey
                              .shade200,

                          child:
                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.image_not_supported,
                                size:
                                60,
                                color:
                                isDark
                                    ? Colors.white54
                                    : Colors.grey,
                              ),

                              const SizedBox(
                                  height:
                                  10),

                              Text(
                                'لا توجد صورة',
                                style:
                                TextStyle(
                                  color:
                                  isDark
                                      ? Colors.white54
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ================= CONTENT =================

                      Padding(
                        padding:
                        const EdgeInsets.all(
                          18,
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            // ================= TITLE =================

                            Text(
                              job.nameJob,

                              style:
                              TextStyle(
                                fontSize:
                                22,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color:
                                isDark
                                    ? Colors
                                    .white
                                    : const Color(
                                  0xFF2A2A2A,
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            // ================= DESCRIPTION =================

                            if (job.description !=
                                null)

                              Text(
                                job.description!,

                                style:
                                TextStyle(
                                  height:
                                  1.7,
                                  fontSize:
                                  15,
                                  color:
                                  isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),

                            const SizedBox(
                                height: 18),

                            // ================= INFO =================

                            _buildInfoRow(
                              icon: Icons
                                  .location_on_outlined,
                              text: job.location ??
                                  'غير محدد',
                              isDark:
                              isDark,
                            ),

                            const SizedBox(
                                height: 12),

                            _buildInfoRow(
                              icon: Icons
                                  .work_outline,
                              text: job.jobType ??
                                  'غير محدد',
                              isDark:
                              isDark,
                            ),

                            const SizedBox(
                                height: 12),

                            _buildInfoRow(
                              icon: Icons
                                  .calendar_month,
                              text: job.deadline !=
                                  null
                                  ? job
                                  .deadline!
                                  .toLocal()
                                  .toString()
                                  .split(
                                  ' ')[0]
                                  : 'لا يوجد موعد نهائي',

                              isDark:
                              isDark,
                            ),

                            const SizedBox(
                                height: 20),

                            Divider(
                              color: isDark
                                  ? Colors
                                  .white12
                                  : Colors
                                  .grey
                                  .shade300,
                            ),

                            const SizedBox(
                                height: 10),

                            // ================= ACTIONS =================

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,

                              children: [

                                // ================= LIKE =================

                                InkWell(
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),

                                  onTap: () =>
                                      _toggleLike(
                                        job,
                                      ),

                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(
                                      8,
                                    ),

                                    child:
                                    Row(
                                      children: [

                                        Icon(
                                          job.isLikedByCurrentUser
                                              ? Icons.favorite
                                              : Icons.favorite_border,

                                          color: job.isLikedByCurrentUser
                                              ? Colors.red
                                              : (isDark
                                              ? Colors.white60
                                              : Colors.grey),

                                          size:
                                          26,
                                        ),

                                        const SizedBox(
                                            width:
                                            6),

                                        Text(
                                          '${job.numberOfLike ?? 0}',

                                          style:
                                          TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ================= COMMENT =================

                                InkWell(
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),

                                  onTap: () {
                                    Navigator
                                        .push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                            context,
                                            ) =>
                                            CommentsScreen(
                                              jobId:
                                              job.idJob,
                                            ),
                                      ),
                                    );
                                  },

                                  child:
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(
                                      8,
                                    ),

                                    child:
                                    Row(
                                      children: [

                                        Icon(
                                          Icons.comment_outlined,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.grey,
                                        ),

                                        const SizedBox(
                                            width:
                                            6),

                                        Text(
                                          '${job.commentCount ?? 0}',

                                          style:
                                          TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ================= SHARE =================

                                InkWell(
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),

                                  onTap:
                                      () {},

                                  child:
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(
                                      8,
                                    ),

                                    child:
                                    Icon(
                                      Icons.share_outlined,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.grey,
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ================= INFO ROW =================

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [

        Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: const Color(0xFF4FA8D8)
                .withOpacity(0.1),

            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF4FA8D8),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,

            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}