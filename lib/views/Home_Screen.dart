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
import 'package:codex_firebase/modelview/language_vm.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/model/advertisement_job.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ Stream مباشر بدل Future — يتحدث تلقائياً
  final Stream<QuerySnapshot> _jobsStream = FirebaseFirestore.instance
      .collection('jobs')
      .orderBy('createdAt', descending: true)
      .snapshots();

  final Set<String> _pendingLikes = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ toggleLike بدون إعادة تحميل — الـ Stream يُحدّث UI تلقائياً
  Future<void> _toggleLike(AdvertisementJob job) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    if (_pendingLikes.contains(job.idJob)) return;

    setState(() => _pendingLikes.add(job.idJob));

    final isLiked = job.likes?.contains(userId) ?? false;
    try {
      await _firestore.collection('jobs').doc(job.idJob).update(
        isLiked
            ? {
          'likes': FieldValue.arrayRemove([userId]),
          'numberOfLike': FieldValue.increment(-1),
        }
            : {
          'likes': FieldValue.arrayUnion([userId]),
          'numberOfLike': FieldValue.increment(1),
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('فشل تحديث الإعجاب'),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TSizes.borderRaduisMd)),
          margin: const EdgeInsets.all(TSizes.md),
        ));
      }
    } finally {
      if (mounted) setState(() => _pendingLikes.remove(job.idJob));
    }
  }

  String _getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return '';
    return Provider.of<AppwriteStorageService>(context, listen: false)
        .getImageUrl(imageId);
  }

  Future<void> _addSampleData() async {
    final loc =
        Provider.of<Language_Vm>(context, listen: false).localization;
    final seed = SeedData();
    await seed.addSampleJobs();
    await seed.addSampleProducts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.sampleDataAdded),
        backgroundColor: TColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.borderRaduisMd)),
        margin: const EdgeInsets.all(TSizes.md),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<Theme_Vm>().isDarkMode;
    final loc = context.watch<Language_Vm>().localization;
    final connectivity = context.watch<ConnectivityService>();

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,

      // ✅ FABs
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_post_fab',
            onPressed: connectivity.isConnected
                ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddPostView()),
              );
            }
                : null,
            backgroundColor: TColors.primary,
            child: const Icon(Icons.add, color: TColors.white, size: 28),
          ),
          const SizedBox(height: TSizes.sm),
          FloatingActionButton.small(
            heroTag: 'ai_chat_fab',
            onPressed: connectivity.isConnected
                ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AiChatScreen()),
            )
                : null,
            backgroundColor: TColors.primary,
            child: const Icon(Icons.auto_awesome,
                color: TColors.white, size: 18),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: RefreshIndicator(
        color: TColors.primary,
        onRefresh: () async {}, // Stream يتحدث تلقائياً
        child: CustomScrollView(
          slivers: [
            // ══════════════════════════════════
            // SliverAppBar
            // ══════════════════════════════════
            SliverAppBar(
              backgroundColor: TColors.primary,
              elevation: 0,
              floating: true,
              automaticallyImplyLeading: false,
              title: Text(
                loc.appName,
                style: const TextStyle(
                  color: TColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.fontSizeLg,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: connectivity.isConnected
                      ? _addSampleData
                      : null,
                  icon: const Icon(Icons.add_circle_outline,
                      color: TColors.white),
                  tooltip: loc.addSampleData,
                ),
                IconButton(
                  onPressed: () =>
                      context.read<Theme_Vm>().toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: TColors.white,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(62),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      TSizes.md, 0, TSizes.md, TSizes.sm),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? TColors.darkerGrey
                          : TColors.white,
                      borderRadius: BorderRadius.circular(
                          TSizes.borderRaduisMd),
                    ),
                    child: TextField(
                      controller: _searchController,
                      enabled: connectivity.isConnected,
                      style: TextStyle(
                          color: isDark
                              ? TColors.white
                              : TColors.black),
                      decoration: InputDecoration(
                        hintText: connectivity.isConnected
                            ? loc.search
                            : loc.noInternet,
                        hintStyle: TextStyle(
                            color: isDark
                                ? TColors.grey
                                : Colors.grey),
                        prefixIcon: Icon(Icons.search,
                            color: isDark
                                ? TColors.grey
                                : Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ══════════════════════════════════
            // Body
            // ══════════════════════════════════
            if (!connectivity.isConnected)
              const SliverFillRemaining(
                child: NoInternetWidget(),
              )
            else
              _buildJobsSliver(isDark, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsSliver(bool isDark, dynamic loc) {
    return StreamBuilder<QuerySnapshot>(
      stream: _jobsStream,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                  color: TColors.primary),
            ),
          );
        }

        // Error
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: Icons.error_outline_rounded,
              iconColor: TColors.error,
              message: loc.errorOccurred,
              isDark: isDark,
              action: ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(loc.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          TSizes.borderRaduisMd)),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: Icons.work_off_rounded,
              iconColor:
              isDark ? Colors.white38 : Colors.grey.shade400,
              message: loc.noJobsAvailable,
              isDark: isDark,
              subtitle: loc.addJobHint,
            ),
          );
        }

        // ✅ تحويل + فلترة البحث
        var jobs = snapshot.data!.docs
            .map((doc) => AdvertisementJob.fromFirestore(doc))
            .toList();

        if (_searchQuery.isNotEmpty) {
          jobs = jobs.where((job) {
            final name = job.nameJob.toLowerCase();
            final desc =
            (job.description ?? '').toLowerCase();
            final loc_ =
            (job.location ?? '').toLowerCase();
            return name.contains(_searchQuery) ||
                desc.contains(_searchQuery) ||
                loc_.contains(_searchQuery);
          }).toList();
        }

        if (jobs.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: Icons.search_off_rounded,
              iconColor:
              isDark ? Colors.white38 : Colors.grey.shade400,
              message: 'لا توجد نتائج لـ "$_searchQuery"',
              isDark: isDark,
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              TSizes.md, TSizes.md, TSizes.md, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final job = jobs[index];
                return _JobCard(
                  job: job,
                  imageUrl: _getImageUrl(job.imageId),
                  isDark: isDark,
                  loc: loc,
                  isPendingLike:
                  _pendingLikes.contains(job.idJob),
                  onLike: () => _toggleLike(job),
                  onComment: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(
                          jobId: job.idJob),
                    ),
                  ),
                );
              },
              childCount: jobs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required Color iconColor,
    required String message,
    required bool isDark,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : const Color(0xFFF0F7FA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: iconColor),
            ),
            const SizedBox(height: TSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: TSizes.fontSizeLg,
                fontWeight: FontWeight.bold,
                color: isDark ? TColors.white : TColors.black,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: TSizes.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  color:
                  isDark ? TColors.grey : TColors.darkGrey,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: TSizes.md),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// _JobCard — بطاقة مستقلة
// ═══════════════════════════════════════════════
class _JobCard extends StatelessWidget {
  final AdvertisementJob job;
  final String imageUrl;
  final bool isDark;
  final dynamic loc;
  final bool isPendingLike;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _JobCard({
    required this.job,
    required this.imageUrl,
    required this.isDark,
    required this.loc,
    required this.isPendingLike,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.md),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        borderRadius:
        BorderRadius.circular(TSizes.cardRaduisMd),
        border: isDark
            ? Border.all(color: Colors.white10)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ════ الصورة ════
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft:
                  Radius.circular(TSizes.cardRaduisMd),
                  topRight:
                  Radius.circular(TSizes.cardRaduisMd),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _placeholder(),
                )
                    : _placeholder(),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    TSizes.md, TSizes.md, TSizes.md, TSizes.sm),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ════ اسم الوظيفة ════
                    Text(
                      job.nameJob,
                      style: TextStyle(
                        fontSize: TSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? TColors.white
                            : const Color(0xFF1A2E3B),
                      ),
                    ),

                    if (job.description != null &&
                        job.description!.isNotEmpty) ...[
                      const SizedBox(height: TSizes.xs),
                      Text(
                        job.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: TSizes.fontSizeSm,
                          height: 1.6,
                          color: isDark
                              ? TColors.white
                              .withOpacity(0.6)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],

                    const SizedBox(height: TSizes.sm),

                    // ════ Info Chips ════
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      text: job.location ?? loc.locationUnknown,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    _InfoChip(
                      icon: Icons.work_outline_rounded,
                      text: job.jobType ?? loc.typeUnknown,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    _InfoChip(
                      icon: Icons.calendar_month_outlined,
                      text: job.deadline != null
                          ? '${loc.deadlineLabel}: ${job.deadline!.toLocal().toString().split(' ')[0]}'
                          : loc.noDeadline,
                      isDark: isDark,
                    ),

                    const SizedBox(height: TSizes.sm),
                    Divider(
                        color: isDark
                            ? Colors.white10
                            : Colors.grey.shade100),
                    const SizedBox(height: 4),

                    // ════ Actions ════
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                      children: [
                        _LikeButton(
                          isLiked: job.isLikedByCurrentUser,
                          count: job.numberOfLike ?? 0,
                          isPending: isPendingLike,
                          isDark: isDark,
                          onTap: onLike,
                        ),
                        _ActionButton(
                          icon: Icons
                              .chat_bubble_outline_rounded,
                          label: '${job.commentCount ?? 0}',
                          color: isDark
                              ? Colors.white38
                              : Colors.grey.shade400,
                          onTap: onComment,
                        ),
                        _ActionButton(
                          icon: Icons.share_outlined,
                          label: '',
                          color: isDark
                              ? Colors.white38
                              : Colors.grey.shade400,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ════ Status Badge ════
          Positioned(
            top: 12,
            right: 12,
            child: _StatusBadge(isOpen: job.isOpen, loc: loc),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF0F7FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRaduisMd),
          topRight: Radius.circular(TSizes.cardRaduisMd),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 32,
              color: isDark
                  ? Colors.white24
                  : Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(
            loc.noImage,
            style: TextStyle(
                fontSize: TSizes.fontSizeSm,
                color: isDark
                    ? Colors.white24
                    : Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// _LikeButton — أنيميشن ScaleTransition
// ═══════════════════════════════════════════════
class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int count;
  final bool isPending;
  final bool isDark;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isLiked,
    required this.count,
    required this.isPending,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.red;
    final inactiveColor =
    isDark ? Colors.white38 : Colors.grey.shade400;
    final currentColor = isLiked ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: isPending ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: isPending
                  ? SizedBox(
                key: const ValueKey('loading'),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: inactiveColor),
              )
                  : Icon(
                key: ValueKey(isLiked),
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: currentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '$count',
                key: ValueKey(count),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: TSizes.fontSizeSm,
                  color: currentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// _StatusBadge
// ═══════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  final dynamic loc;
  const _StatusBadge({required this.isOpen, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? TColors.success : TColors.error,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? TColors.success : TColors.error)
                .withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: TColors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? loc.open : loc.closed,
            style: const TextStyle(
              color: TColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// _InfoChip
// ═══════════════════════════════════════════════
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoChip(
      {required this.icon,
        required this.text,
        required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: TColors.primary, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: isDark
                  ? Colors.white60
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// _ActionButton
// ═══════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: TSizes.fontSizeSm,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}