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
  // ✅ تعديل: جعل الـ Future يقبل الـ null وتجنب late لمنع الانهيار
  Future<List<AdvertisementJob>>? _jobsFuture;
  bool _isConnected = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final connectivity = Provider.of<ConnectivityService>(context, listen: false);
    _isConnected = connectivity.isConnected;
    if (_isConnected) {
      setState(() {
        _jobsFuture = context.read<Advertisement_of_jop_Vm>().getAllJobs();
      });
    } else {
      setState(() {
        _jobsFuture = Future.value([]); // ✅ إرجاع قائمة فارغة آمنة عند عدم وجود اتصال
      });
    }
  }

  void _retryLoad() {
    _loadData();
  }

  void _refreshData() {
    _loadData();
  }

  Future<void> _addSampleData() async {
    final seed = SeedData();
    await seed.addSampleJobs();
    await seed.addSampleProducts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة بيانات تجريبية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshData();
    }
  }

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

  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';
    final storageService = Provider.of<AppwriteStorageService>(context, listen: false);
    return storageService.getImageUrl(imageId);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<Theme_Vm>(context);
    final bool isDark = themeProvider.isDarkMode;
    final connectivity = Provider.of<ConnectivityService>(context);

    if (connectivity.isConnected != _isConnected) {
      _isConnected = connectivity.isConnected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add_post_fab",
            onPressed: _isConnected
                ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostView()),
              );
              _refreshData();
            }
                : null,
            backgroundColor: TColors.primary,
            child: const Icon(Icons.add, color: TColors.white, size: 30),
          ),
          const SizedBox(height: TSizes.sm),
          FloatingActionButton.small(
            heroTag: "ai_chat_fab",
            onPressed: _isConnected
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            }
                : null,
            backgroundColor: TColors.primary,
            child: const Icon(Icons.auto_awesome, color: TColors.white, size: 20),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () async {
          if (_isConnected) {
            _refreshData();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: TColors.primary,
              elevation: 0,
              floating: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: _isConnected ? _addSampleData : null,
                  icon: const Icon(Icons.add_circle_outline, color: TColors.white),
                  tooltip: 'إضافة بيانات تجريبية',
                ),
                IconButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: TColors.white,
                  ),
                ),
              ],
              title: const Text(
                'CODEX',
                style: TextStyle(color: TColors.white, fontWeight: FontWeight.bold),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.sm),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkerGrey : TColors.white,
                      borderRadius: BorderRadius.circular(TSizes.borderRaduisMd),
                    ),
                    child: TextField(
                      enabled: _isConnected,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: isDark ? TColors.white : TColors.black),
                      decoration: InputDecoration(
                        hintText: _isConnected ? 'بحث' : 'لا يوجد اتصال بالإنترنت',
                        hintStyle: TextStyle(color: isDark ? TColors.grey : Colors.grey),
                        hintTextDirection: TextDirection.rtl,
                        prefixIcon: Icon(Icons.search, color: isDark ? TColors.grey : Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!_isConnected)
              const SliverFillRemaining(
                child: NoInternetWidget(),
              )
            else
              FutureBuilder<List<AdvertisementJob>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: TColors.primary)),
                    );
                  }
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
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
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 80,
                              color: isDark ? TColors.grey : TColors.darkGrey,
                            ),
                            const SizedBox(height: TSizes.md),
                            Text(
                              'لا توجد وظائف متاحة',
                              style: TextStyle(
                                fontSize: TSizes.fontSizeLg,
                                color: isDark ? TColors.grey : TColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: TSizes.md),
                            Text(
                              'اضغط على زر + لإضافة وظيفة جديدة',
                              style: TextStyle(
                                color: isDark ? TColors.grey : TColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final List<AdvertisementJob> jobs = snapshot.data!;

                  return SliverPadding(
                    padding: const EdgeInsets.all(TSizes.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final job = jobs[index];
                          final imageUrl = _getImageUrl(job.imageId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: TSizes.md),
                            decoration: BoxDecoration(
                              color: isDark ? TColors.darkerGrey : const Color(0xFFF0F7FA),
                              borderRadius: BorderRadius.circular(TSizes.cardRaduisMd),
                              border: isDark ? Border.all(color: Colors.white10) : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(TSizes.cardRaduisMd),
                                      topRight: Radius.circular(TSizes.cardRaduisMd),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          color: isDark ? Colors.black26 : TColors.grey,
                                          child: const Icon(Icons.broken_image, size: 50),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Container(
                                    height: 200,
                                    color: isDark ? Colors.black26 : TColors.grey,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: isDark ? TColors.grey : Colors.white70,
                                          ),
                                          const SizedBox(height: TSizes.sm),
                                          Text(
                                            'لا توجد صورة',
                                            style: TextStyle(
                                              color: isDark ? TColors.grey : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(TSizes.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.nameJob,
                                        style: TextStyle(
                                          fontSize: TSizes.fontSizeLg,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? TColors.accent : const Color(0xFF429EBD),
                                        ),
                                      ),
                                      const SizedBox(height: TSizes.sm),

                                      if (job.description != null && job.description!.isNotEmpty)
                                        Text(
                                          job.description!,
                                          style: TextStyle(
                                            fontSize: TSizes.fontSizeSm,
                                            color: isDark ? TColors.white.withOpacity(0.9) : TColors.textprimary,
                                          ),
                                        ),
                                      const SizedBox(height: TSizes.md),

                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: isDark ? TColors.grey : TColors.darkGrey),
                                          const SizedBox(width: TSizes.xs),
                                          Expanded(
                                            child: Text(
                                              job.location ?? 'موقع غير محدد',
                                              style: TextStyle(
                                                fontSize: TSizes.fontSizeSm,
                                                color: isDark ? TColors.grey : TColors.darkGrey,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.work, size: 16, color: isDark ? TColors.grey : TColors.darkGrey),
                                          const SizedBox(width: TSizes.xs),
                                          Text(
                                            job.jobType ?? 'نوع غير محدد',
                                            style: TextStyle(
                                              fontSize: TSizes.fontSizeSm,
                                              color: isDark ? TColors.grey : TColors.darkGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: TSizes.sm),

                                      Row(
                                        children: [
                                          Icon(Icons.today, size: 16, color: isDark ? TColors.grey : TColors.darkGrey),
                                          const SizedBox(width: TSizes.xs),
                                          Expanded(
                                            child: Text(
                                              job.deadline != null
                                                  ? 'الموعد النهائي: ${job.deadline!.toLocal().toString().split(' ')[0]}'
                                                  : 'لا يوجد موعد نهائي',
                                              style: TextStyle(
                                                fontSize: TSizes.fontSizeSm,
                                                color: isDark ? TColors.grey : TColors.darkGrey,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: TSizes.sm,
                                              vertical: TSizes.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: job.isOpen ? TColors.success : TColors.error,
                                              borderRadius: BorderRadius.circular(TSizes.borderRaduisSm),
                                            ),
                                            child: Text(
                                              job.isOpen ? 'مفتوح' : 'مغلق',
                                              style: const TextStyle(
                                                color: TColors.white,
                                                fontSize: TSizes.fontSizeSm,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: TSizes.md),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            onTap: () => _toggleLike(job),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  job.isLikedByCurrentUser
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: job.isLikedByCurrentUser
                                                      ? Colors.red
                                                      : (isDark ? TColors.grey : TColors.darkGrey),
                                                  size: 24,
                                                ),
                                                const SizedBox(width: TSizes.xs),
                                                Text(
                                                  '${job.numberOfLike ?? 0}',
                                                  style: TextStyle(
                                                    color: isDark ? TColors.grey : TColors.darkGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CommentsScreen(
                                                    jobId: job.idJob,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.comment_outlined,
                                                  color: isDark ? TColors.grey : TColors.darkGrey,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: TSizes.xs),
                                                Text(
                                                  '${job.commentCount ?? 0}',
                                                  style: TextStyle(
                                                    color: isDark ? TColors.grey : TColors.darkGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Icon(
                                              Icons.share_outlined,
                                              color: isDark ? TColors.grey : TColors.darkGrey,
                                              size: 24,
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
}