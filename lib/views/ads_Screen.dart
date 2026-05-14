import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/modelview/adv_job_vm.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/services/connectivity_service.dart';
import 'package:codex_firebase/views/no_internet_widget.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  late Future<List<dynamic>> _jobsFuture;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final connectivity = Provider.of<ConnectivityService>(context, listen: false);
    _isConnected = connectivity.isConnected;
    if (_isConnected) {
      _jobsFuture = context.read<Advertisement_of_jop_Vm>().getAllJobs();
    }
  }

  void _retryLoad() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final connectivity = Provider.of<ConnectivityService>(context);

    if (connectivity.isConnected != _isConnected) {
      _isConnected = connectivity.isConnected;
      if (_isConnected) {
        _loadData();
      }
      setState(() {});
    }

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.white,
      appBar: AppBar(
        title: const Text('إعلانات الوظائف'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: !_isConnected
          ? const NoInternetWidget()
          : FutureBuilder<List<dynamic>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: TColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
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
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'لا توجد إعلانات وظائف حالياً',
                style: TextStyle(color: isDark ? TColors.white : TColors.black),
              ),
            );
          }

          final jobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(TSizes.md),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
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
                    if (job.image != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(TSizes.cardRaduisMd),
                          topRight: Radius.circular(TSizes.cardRaduisMd),
                        ),
                        child: Image.network(
                          job.image!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: isDark ? Colors.black26 : TColors.grey,
                              child: const Icon(Icons.broken_image),
                            );
                          },
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
                          if (job.description != null)
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}