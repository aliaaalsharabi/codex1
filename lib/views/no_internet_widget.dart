import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';
import 'package:codex_firebase/modelview/theme_vm.dart';
import 'package:codex_firebase/modelview/language_vm.dart';

class NoInternetWidget extends StatefulWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({super.key, this.onRetry});

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _isRetrying = false;

  static const Color _primaryBlue = Color(0xFF429EBD);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    // ✅ أنيميشن إعادة تحميل
    await _controller.reverse();
    await Future.delayed(const Duration(milliseconds: 300));

    widget.onRetry?.call();

    if (mounted) {
      _controller.forward();
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Theme_Vm>(context).isDarkMode;
    final loc = Provider.of<Language_Vm>(context).localization;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ أيقونة مع حلقة خلفية
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.signal_wifi_off_rounded,
                        size: 46,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ العنوان
                Text(
                  loc.noInternetTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? TColors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ الوصف
                Text(
                  loc.noInternetSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? TColors.grey : Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ نصائح صغيرة
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? TColors.darkerGrey
                        : const Color(0xFFF5FAFD),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _primaryBlue.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildTip(
                        isDark: isDark,
                        icon: Icons.wifi_outlined,
                        text: 'تحقق من اتصال الـ Wi-Fi',
                      ),
                      const SizedBox(height: 8),
                      _buildTip(
                        isDark: isDark,
                        icon: Icons.signal_cellular_alt_outlined,
                        text: 'تحقق من بيانات الجوال',
                      ),
                      const SizedBox(height: 8),
                      _buildTip(
                        isDark: isDark,
                        icon: Icons.airplanemode_active_outlined,
                        text: 'تأكد أن وضع الطيران مغلق',
                      ),
                    ],
                  ),
                ),

                if (widget.onRetry != null) ...[
                  const SizedBox(height: 24),

                  // ✅ زر إعادة المحاولة — نفس أسلوب Login
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isRetrying ? null : _handleRetry,
                      icon: _isRetrying
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        _isRetrying ? 'جاري الاتصال...' : loc.retry,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        disabledBackgroundColor:
                        _primaryBlue.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip({
    required bool isDark,
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _primaryBlue),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? TColors.grey : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}