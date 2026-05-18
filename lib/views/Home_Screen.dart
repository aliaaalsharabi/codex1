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

// 👇 أضفنا هذا
import 'package:codex_firebase/views/MainWrapper.dart';

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

    final storageService =
    Provider.of<AppwriteStorageService>(context, listen: false);

    return storageService.getImageUrl(imageId);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<Theme_Vm>(context);
    final bool isDark = themeProvider.isDarkMode;
    final connectivity = Provider.of<ConnectivityService>(context);

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

      /// 👇 هنا ربطنا شريط MainWrapper السفلي
      bottomNavigationBar: const MainWrapper(),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                    builder: (context) => const AiChatScreen(),
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
                    builder: (context) => const AddPostView(),
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
                  child: const SafeArea(
                    child: Center(
                      child: Text(
                        "CODEX",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final jobs = snapshot.data ?? [];

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final job = jobs[index];

                        return ListTile(
                          title: Text(job.nameJob),
                        );
                      },
                      childCount: jobs.length,
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