import 'package:flutter/material.dart';
import 'package:codex_firebase/constants/colors.dart';
import 'package:codex_firebase/constants/sizes.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_off,
              size: 80,
              color: TColors.error,
            ),
            const SizedBox(height: TSizes.md),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TColors.error,
              ),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت\nوإعادة المحاولة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: TColors.darkGrey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: TSizes.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}