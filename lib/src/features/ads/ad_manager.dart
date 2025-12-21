import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdManager handles interstitial ad loading and display
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _copyCount = 0;

  /// Test Ad Unit IDs
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  /// Check if ads are supported on this platform
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  /// Get interstitial ad unit ID based on platform
  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
    // TODO: Replace with real ad unit IDs for production
    if (Platform.isAndroid) {
      return _testInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _testInterstitialAdUnitId;
    }
    return _testInterstitialAdUnitId;
  }

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    // Only initialize on supported platforms (iOS/Android)
    if (!isSupported) {
      debugPrint('AdMob not supported on this platform');
      return;
    }
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  /// Pre-load interstitial ad
  void _loadInterstitialAd() {
    if (!isSupported) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setAdCallbacks();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Set callbacks for the loaded ad
  void _setAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdLoaded = false;
        // Reload the next ad immediately
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _isAdLoaded = false;
        _loadInterstitialAd();
      },
    );
  }

  /// Increment copy counter and show ad if condition is met
  /// Returns true if ad was shown
  Future<bool> onCopyTriggered() async {
    _copyCount++;

    // Show ad every 3rd copy
    if (_copyCount % 3 == 0 && _isAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    }
    return false;
  }

  /// Get current copy count (for debugging)
  int get copyCount => _copyCount;

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
  }
}
