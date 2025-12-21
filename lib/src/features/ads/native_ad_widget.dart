import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../app.dart';
import 'ad_manager.dart';

/// A compact native ad widget (60px height) styled as a card
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Only load ads on mobile platforms
    if (Platform.isIOS || Platform.isAndroid) {
      _loadAd();
    }
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdManager.testNativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.primary,
          style: NativeTemplateFontStyle.bold,
          size: 12,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textPrimary,
          style: NativeTemplateFontStyle.bold,
          size: 13,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSecondary,
          style: NativeTemplateFontStyle.normal,
          size: 11,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSecondary,
          style: NativeTemplateFontStyle.normal,
          size: 10,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show on mobile platforms (iOS/Android)
    if (!Platform.isIOS && !Platform.isAndroid) {
      return _buildPlaceholder();
    }

    if (!_isAdLoaded) {
      return _buildPlaceholder();
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _nativeAd!),
    );
  }

  /// Placeholder widget when ad is not loaded or on non-mobile platforms
  Widget _buildPlaceholder() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.separator,
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ads_click,
              size: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'Ad',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
