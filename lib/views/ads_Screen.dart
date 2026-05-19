import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/services/appwrite_storage_service.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/views/Comments_Screen.dart';
import 'package:codex_firebase/model/advertisement_job.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

const Color _primary = Color(0xFF429EBD);

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  // ✅ Stream مباشر من Firestore
  final Stream<QuerySnapshot> _jobsStream = FirebaseFirestore.instance
      .collection('jobs')
      .orderBy('createdAt', descending: true)
      .snapshots();

  final Set<String> _pendingLikes = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ toggleLike بدون إعادة تحميل — Firebase يُحدّث الـ Stream تلقائياً
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
      // ✅ لا داعي لأي setState هنا — الـ Stream يحدّث الـ UI تلقائياً
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('فشل تحديث الإعجاب'),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(14),
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

  @override
  Widget build(BuildContext context) {
    final isDark       = context.watch<Theme_Vm>().isDarkMode;
    final connectivity = context.watch<ConnectivityService>();
    final loc          = context.watch<Language_Vm>().localization;
    final Color bg     = isDark ? const Color(0xFF121212) : const Color(0xFFF5FAFD);

    return Scaffold(
      backgroundColor: bg,
      body: !connectivity.isConnected
          ? const NoInternetWidget()
          : StreamBuilder<QuerySnapshot>(
        stream: _jobsStream,
        builder: (context, snapshot) {

          // ===== Loading =====
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          // ===== Error =====
          if (snapshot.hasError) {
            return _buildEmptyState(
              icon: Icons.error_outline_rounded,
              iconColor: Colors.red,
              message: loc.errorOccurred,
              isDark: isDark,
              action: TextButton(
                onPressed: () => setState(() {}),
                child: Text(loc.retry,
                    style: const TextStyle(color: _primary)),
              ),
            );
          }

          // ===== Empty =====
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              icon: Icons.work_off_rounded,
              iconColor: isDark ? Colors.white38 : Colors.grey.shade400,
              message: loc.noJobs,
              isDark: isDark,
            );
          }

          // ✅ تحويل الـ docs لـ AdvertisementJob مباشرةً
          final jobs = snapshot.data!.docs
              .map((doc) => AdvertisementJob.fromFirestore(doc))
              .toList();

          // ===== List =====
          return RefreshIndicator(
            color: _primary,
            onRefresh: () async {}, // ✅ Stream يتحدث تلقائياً
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _JobCard(
                  job: job,
                  imageUrl: _getImageUrl(job.imageId),
                  isDark: isDark,
                  loc: loc,
                  isPendingLike: _pendingLikes.contains(job.idJob),
                  onLike: () => _toggleLike(job),
                  onComment: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(jobId: job.idJob),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required Color iconColor,
    required String message,
    required bool isDark,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }
}

// ===========================================
// ===== Job Card =====
// ===========================================
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
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
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

              // ===== الصورة =====
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      job.nameJob,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A2E3B),
                      ),
                    ),

                    if (job.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        job.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    _InfoChip(icon: Icons.location_on_outlined,
                        text: job.location ?? loc.locationUnknown, isDark: isDark),
                    const SizedBox(height: 6),
                    _InfoChip(icon: Icons.work_outline_rounded,
                        text: job.jobType ?? loc.typeUnknown, isDark: isDark),
                    const SizedBox(height: 6),
                    _InfoChip(
                      icon: Icons.calendar_month_outlined,
                      text: job.deadline != null
                          ? job.deadline!.toLocal().toString().split(' ')[0]
                          : loc.noDeadline,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),
                    Divider(color: isDark ? Colors.white10 : Colors.grey.shade100),
                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LikeButton(
                          isLiked: job.isLikedByCurrentUser,
                          count: job.numberOfLike ?? 0,
                          isPending: isPendingLike,
                          isDark: isDark,
                          onTap: onLike,
                        ),
                        _ActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '${job.commentCount ?? 0}',
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                          onTap: onComment,
                        ),
                        _ActionButton(
                          icon: Icons.share_outlined,
                          label: '',
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ===== Badge =====
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
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 32, color: isDark ? Colors.white24 : Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(
            loc.noImage,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white24 : Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ===== Like Button =====
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
    final Color activeColor   = Colors.red;
    final Color inactiveColor = isDark ? Colors.white38 : Colors.grey.shade400;
    final Color currentColor  = isLiked ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: isPending ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    strokeWidth: 2, color: inactiveColor),
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
                  fontSize: 13,
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

// ===== Status Badge =====
class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  final dynamic loc;
  const _StatusBadge({required this.isOpen, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: Colors.white, size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? loc.open : loc.closed,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Info Chip =====
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoChip({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _primary, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== Action Button =====
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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