import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:codex_firebase/views/Add_post_view.dart';
import 'package:codex_firebase/views/Ai_chat_Screen.dart';
import 'package:codex_firebase/views/Comments_Screen.dart';

import 'package:codex_firebase/modelview/adv_job_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';

import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';

import 'package:codex_firebase/views/no_internet_widget.dart';

import 'package:codex_firebase/utils/seed_data.dart';

import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

import 'package:codex_firebase/model/advertisement_job.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<AdvertisementJob>> _jobsFuture;

  bool _isConnected = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final connectivity =
    Provider.of<ConnectivityService>(context, listen: false);

    _isConnected = connectivity.isConnected;

    if (_isConnected) {
      _jobsFuture =
          context.read<Advertisement_of_jop_Vm>().getAllJobs();
    }
  }

  void _retryLoad() {
    setState(() {
      _loadData();
    });
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  Future<void> _addSampleData() async {
    final seed = SeedData();

    await seed.addSampleJobs();
    await seed.addSampleProducts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            'تمت إضافة بيانات تجريبية بنجاح',
            textAlign: TextAlign.center,
          ),
        ),
      );

      _refreshData();
    }
  }

  /// ❤️ الإعجاب
  Future<void> _toggleLike(AdvertisementJob job) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) return;

    final jobRef = _firestore.collection('jobs').doc(job.idJob);

    final isLiked = job.likes?.contains(userId) ?? false;

    if (isLiked) {
      await jobRef.update({
        'likes': FieldValue.arrayRemove([userId]),
        'numberOfLike': FieldValue.increment(-1),
      });
    } else {
      await jobRef.update({
        'likes': FieldValue.arrayUnion([userId]),
        'numberOfLike': FieldValue.increment(1),
      });
    }

    _refreshData();
  }

  /// 🖼️ رابط الصورة
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
    final themeProvider = Provider.of<Theme_Vm>(context);

    final bool isDark = themeProvider.isDarkMode;

    final connectivity =
    Provider.of<ConnectivityService>(context);

    const Color primaryBlue = Color(0xFF5DB1DF);

    if (connectivity.isConnected != _isConnected) {
      _isConnected = connectivity.isConnected;

      if (_isConnected) {
        _loadData();
      }

      setState(() {});
    }

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF101418) : const Color(0xFFF7FAFD),

      /// Floating Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          /// AI CHAT
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.small(
              heroTag: "ai_chat_fab",
              backgroundColor: primaryBlue,
              onPressed: _isConnected
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const AiChatScreen(),
                  ),
                );
              }
                  : null,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// ADD POST
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: "add_post_fab",
              backgroundColor: primaryBlue,
              elevation: 0,
              onPressed: _isConnected
                  ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const AddPostView(),
                  ),
                );

                _refreshData();
              }
                  : null,
              child: const Icon(
                Icons.add_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: () async {
          if (_isConnected) {
            _refreshData();
          }
        },

        child: CustomScrollView(
          slivers: [

            /// APP BAR
            SliverAppBar(
              backgroundColor: primaryBlue,
              elevation: 0,
              floating: true,
              pinned: true,
              expandedHeight: 150,
              automaticallyImplyLeading: false,

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF5DB1DF),
                        Color(0xFF429EBD),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          /// TOP ROW
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [

                              /// LEFT ACTIONS
                              Row(
                                children: [
                                  _buildTopButton(
                                    icon: Icons.add_circle_outline,
                                    onTap: _isConnected
                                        ? _addSampleData
                                        : null,
                                  ),

                                  const SizedBox(width: 10),

                                  _buildTopButton(
                                    icon: isDark
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                    onTap: () {
                                      themeProvider.toggleTheme();
                                    },
                                  ),
                                ],
                              ),

                              /// LOGO
                              const Text(
                                'CODEX',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          /// SEARCH BAR
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(18),
                            ),

                            child: TextField(
                              enabled: _isConnected,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),

                              decoration: InputDecoration(
                                hintText: _isConnected
                                    ? 'ابحث عن وظيفة أو تخصص...'
                                    : 'لا يوجد اتصال بالإنترنت',

                                hintTextDirection:
                                TextDirection.rtl,

                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey,
                                ),

                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey,
                                ),

                                border: InputBorder.none,

                                contentPadding:
                                const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// NO INTERNET
            if (!_isConnected)
              const SliverFillRemaining(
                child: NoInternetWidget(),
              )

            else
              FutureBuilder<List<AdvertisementJob>>(
                future: _jobsFuture,

                builder: (context, snapshot) {

                  /// LOADING
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                        ),
                      ),
                    );
                  }

                  /// ERROR
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [

                            Icon(
                              Icons.error_outline_rounded,
                              size: 80,
                              color: Colors.red.shade400,
                            ),

                            const SizedBox(height: 14),

                            Text(
                              'حدث خطأ: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),

                            const SizedBox(height: 18),

                            ElevatedButton(
                              onPressed: _retryLoad,

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),

                              child: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  /// EMPTY
                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [

                            Container(
                              padding:
                              const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: primaryBlue
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.work_off_rounded,
                                size: 70,
                                color: primaryBlue,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              'لا توجد وظائف متاحة',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'اضغط على زر + لإضافة وظيفة جديدة',
                              style: TextStyle(
                                color: isDark
                                    ? TColors.grey
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final jobs = snapshot.data!;

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),

                    sliver: SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {

                          final job = jobs[index];

                          final imageUrl =
                          _getImageUrl(job.imageId);

                          return Container(
                            margin:
                            const EdgeInsets.only(
                              bottom: 22,
                            ),

                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1B222C)
                                  : Colors.white,

                              borderRadius:
                              BorderRadius.circular(
                                26,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.05),
                                  blurRadius: 18,
                                  offset:
                                  const Offset(0, 8),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                /// IMAGE
                                ClipRRect(
                                  borderRadius:
                                  const BorderRadius.only(
                                    topLeft:
                                    Radius.circular(26),
                                    topRight:
                                    Radius.circular(26),
                                  ),

                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    height: 210,
                                    width:
                                    double.infinity,
                                    fit: BoxFit.cover,

                                    errorBuilder:
                                        (
                                        context,
                                        error,
                                        stackTrace,
                                        ) {
                                      return Container(
                                        height: 210,
                                        color: Colors
                                            .grey
                                            .shade300,
                                        child:
                                        const Icon(
                                          Icons
                                              .broken_image_rounded,
                                          size: 55,
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    height: 210,
                                    color: Colors
                                        .grey
                                        .shade300,

                                    child: const Center(
                                      child: Icon(
                                        Icons
                                            .image_not_supported_outlined,
                                        size: 55,
                                      ),
                                    ),
                                  ),
                                ),

                                /// CONTENT
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

                                      /// JOB NAME
                                      Text(
                                        job.nameJob,

                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(
                                            0xFF2B4B5F,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      /// DESCRIPTION
                                      if (job.description !=
                                          null &&
                                          job.description!
                                              .isNotEmpty)
                                        Text(
                                          job.description!,

                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.7,
                                            color: isDark
                                                ? Colors
                                                .white70
                                                : Colors
                                                .black87,
                                          ),
                                        ),

                                      const SizedBox(
                                        height: 18,
                                      ),

                                      /// LOCATION + TYPE
                                      Row(
                                        children: [

                                          Expanded(
                                            child:
                                            _buildInfoChip(
                                              icon: Icons
                                                  .location_on_outlined,
                                              text:
                                              job.location ??
                                                  'موقع غير محدد',
                                              isDark:
                                              isDark,
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 10,
                                          ),

                                          Expanded(
                                            child:
                                            _buildInfoChip(
                                              icon: Icons
                                                  .work_outline,
                                              text:
                                              job.jobType ??
                                                  'غير محدد',
                                              isDark:
                                              isDark,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 14,
                                      ),

                                      /// DATE + STATUS
                                      Row(
                                        children: [

                                          Expanded(
                                            child:
                                            _buildInfoChip(
                                              icon: Icons
                                                  .calendar_today_outlined,
                                              text: job.deadline !=
                                                  null
                                                  ? 'الموعد النهائي: ${job.deadline!.toLocal().toString().split(' ')[0]}'
                                                  : 'لا يوجد موعد نهائي',
                                              isDark:
                                              isDark,
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 10,
                                          ),

                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                              14,
                                              vertical: 8,
                                            ),

                                            decoration:
                                            BoxDecoration(
                                              color: job
                                                  .isOpen
                                                  ? Colors
                                                  .green
                                                  : Colors
                                                  .red,

                                              borderRadius:
                                              BorderRadius.circular(
                                                14,
                                              ),
                                            ),

                                            child: Text(
                                              job.isOpen
                                                  ? 'مفتوح'
                                                  : 'مغلق',

                                              style:
                                              const TextStyle(
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      Divider(
                                        color: isDark
                                            ? Colors.white12
                                            : Colors.grey
                                            .shade200,
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      /// ACTIONS
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceAround,

                                        children: [

                                          /// LIKE
                                          _buildActionButton(
                                            icon: job
                                                .isLikedByCurrentUser
                                                ? Icons
                                                .favorite
                                                : Icons
                                                .favorite_border,

                                            text:
                                            '${job.numberOfLike ?? 0}',

                                            color: job
                                                .isLikedByCurrentUser
                                                ? Colors.red
                                                : (isDark
                                                ? Colors
                                                .white70
                                                : Colors
                                                .black54),

                                            onTap: () =>
                                                _toggleLike(
                                                  job,
                                                ),
                                          ),

                                          /// COMMENT
                                          _buildActionButton(
                                            icon: Icons
                                                .comment_outlined,

                                            text:
                                            '${job.commentCount ?? 0}',

                                            color: isDark
                                                ? Colors
                                                .white70
                                                : Colors
                                                .black54,

                                            onTap: () {
                                              Navigator.push(
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
                                          ),

                                          /// SHARE
                                          _buildActionButton(
                                            icon: Icons
                                                .share_outlined,

                                            text: 'مشاركة',

                                            color: isDark
                                                ? Colors
                                                .white70
                                                : Colors
                                                .black54,

                                            onTap: () {},
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

                        childCount: jobs.length,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// TOP BUTTON
  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  /// INFO CHIP
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF4F8FB),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF5DB1DF),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ACTION BUTTON
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),

            const SizedBox(width: 6),

            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}