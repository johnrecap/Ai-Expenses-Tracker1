import 'dart:async';

import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

class AdMobAdConfig {
  const AdMobAdConfig({
    this.androidBannerAdUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_BANNER_AD_UNIT_ID',
    ),
    this.androidInterstitialAdUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID',
    ),
    this.androidRewardedNormalAdUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_REWARDED_NORMAL_AD_UNIT_ID',
    ),
    this.androidRewardedAiAdUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_REWARDED_AI_AD_UNIT_ID',
    ),
    this.iosBannerAdUnitId = const String.fromEnvironment(
      'ADMOB_IOS_BANNER_AD_UNIT_ID',
    ),
    this.iosInterstitialAdUnitId = const String.fromEnvironment(
      'ADMOB_IOS_INTERSTITIAL_AD_UNIT_ID',
    ),
    this.iosRewardedNormalAdUnitId = const String.fromEnvironment(
      'ADMOB_IOS_REWARDED_NORMAL_AD_UNIT_ID',
    ),
    this.iosRewardedAiAdUnitId = const String.fromEnvironment(
      'ADMOB_IOS_REWARDED_AI_AD_UNIT_ID',
    ),
  });

  static const _useTestAdsEnv = String.fromEnvironment('ADMOB_USE_TEST_ADS');

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';

  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';

  final String androidBannerAdUnitId;
  final String androidInterstitialAdUnitId;
  final String androidRewardedNormalAdUnitId;
  final String androidRewardedAiAdUnitId;
  final String iosBannerAdUnitId;
  final String iosInterstitialAdUnitId;
  final String iosRewardedNormalAdUnitId;
  final String iosRewardedAiAdUnitId;

  bool get useTestAds {
    if (_useTestAdsEnv.isEmpty) return !kReleaseMode;
    return _useTestAdsEnv.toLowerCase() == 'true';
  }

  String get bannerAdUnitId {
    if (useTestAds) {
      return _forPlatform(android: _androidTestBanner, ios: _iosTestBanner);
    }
    return _forPlatform(
      android: androidBannerAdUnitId,
      ios: iosBannerAdUnitId,
    );
  }

  String get interstitialAdUnitId {
    if (useTestAds) {
      return _forPlatform(
        android: _androidTestInterstitial,
        ios: _iosTestInterstitial,
      );
    }
    return _forPlatform(
      android: androidInterstitialAdUnitId,
      ios: iosInterstitialAdUnitId,
    );
  }

  String rewardedAdUnitIdFor(AdPlacement placement) {
    if (useTestAds) {
      return _forPlatform(android: _androidTestRewarded, ios: _iosTestRewarded);
    }

    switch (placement) {
      case AdPlacement.rewardedNormalEntries:
        return _forPlatform(
          android: androidRewardedNormalAdUnitId,
          ios: iosRewardedNormalAdUnitId,
        );
      case AdPlacement.rewardedAiEntries:
      case AdPlacement.rewardedAiCredit:
        return _forPlatform(
          android: androidRewardedAiAdUnitId,
          ios: iosRewardedAiAdUnitId,
        );
      case AdPlacement.nonCriticalBanner:
      case AdPlacement.nonCriticalInterstitial:
      case AdPlacement.expenseEntry:
      case AdPlacement.expenseSave:
      case AdPlacement.aiTyping:
      case AdPlacement.aiParsing:
        return '';
    }
  }

  bool get hasUsableAdUnit =>
      bannerAdUnitId.isNotEmpty ||
      interstitialAdUnitId.isNotEmpty ||
      rewardedAdUnitIdFor(AdPlacement.rewardedNormalEntries).isNotEmpty ||
      rewardedAdUnitIdFor(AdPlacement.rewardedAiEntries).isNotEmpty;

  String _forPlatform({required String android, required String ios}) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
    }
  }
}

class AdMobAdService implements AdService {
  AdMobAdService({
    this.config = const AdMobAdConfig(),
    gma.AdRequest? adRequest,
  }) : _adRequest = adRequest ?? const gma.AdRequest();

  final AdMobAdConfig config;
  final gma.AdRequest _adRequest;

  Future<AdServiceStatus>? _initializeFuture;
  gma.BannerAd? _bannerAd;
  gma.InterstitialAd? _interstitialAd;
  gma.RewardedAd? _rewardedAd;
  bool _disposed = false;

  @override
  Future<AdServiceStatus> initialize() {
    return _initializeFuture ??= _initialize();
  }

  Future<AdServiceStatus> _initialize() async {
    if (kIsWeb || !config.hasUsableAdUnit) {
      return const AdServiceStatus.unavailable(
        'AdMob is unavailable because no ad unit configuration was provided.',
      );
    }

    try {
      await gma.MobileAds.instance.initialize();
      return const AdServiceStatus.available('AdMob is available.');
    } catch (_) {
      return const AdServiceStatus.unavailable(
        'AdMob failed to initialize on this device.',
      );
    }
  }

  @override
  Future<AdShowResult> showBanner() async {
    final status = await initialize();
    if (!status.isAvailable) return AdShowResult.unavailable(status.message);

    final adUnitId = config.bannerAdUnitId;
    if (adUnitId.isEmpty) {
      return const AdShowResult.unavailable('AdMob banner ad unit is missing.');
    }

    final completer = Completer<AdShowResult>();
    _bannerAd?.dispose();
    _bannerAd = gma.BannerAd(
      adUnitId: adUnitId,
      request: _adRequest,
      size: gma.AdSize.banner,
      listener: gma.BannerAdListener(
        onAdLoaded: (_) {
          if (!completer.isCompleted) {
            completer.complete(
              const AdShowResult.shown('AdMob banner ad loaded.'),
            );
          }
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (identical(_bannerAd, ad)) _bannerAd = null;
          if (!completer.isCompleted) {
            completer.complete(
              const AdShowResult.unavailable('AdMob banner failed to load.'),
            );
          }
        },
      ),
    )..load();

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _bannerAd?.dispose();
        _bannerAd = null;
        return const AdShowResult.unavailable('AdMob banner load timed out.');
      },
    );
  }

  @override
  Future<AdShowResult> hideBanner() async {
    _bannerAd?.dispose();
    _bannerAd = null;
    return const AdShowResult.shown('AdMob banner disposed.');
  }

  @override
  Future<AdShowResult> showInterstitial() async {
    final status = await initialize();
    if (!status.isAvailable) return AdShowResult.unavailable(status.message);

    final adUnitId = config.interstitialAdUnitId;
    if (adUnitId.isEmpty) {
      return const AdShowResult.unavailable(
        'AdMob interstitial ad unit is missing.',
      );
    }

    final completer = Completer<AdShowResult>();
    await gma.InterstitialAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      adLoadCallback: gma.InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = gma.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (shownAd) {
              shownAd.dispose();
              if (identical(_interstitialAd, shownAd)) _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (shownAd, _) {
              shownAd.dispose();
              if (identical(_interstitialAd, shownAd)) _interstitialAd = null;
              if (!completer.isCompleted) {
                completer.complete(
                  const AdShowResult.unavailable(
                    'AdMob interstitial failed to show.',
                  ),
                );
              }
            },
          );
          ad.show();
          if (!completer.isCompleted) {
            completer.complete(
              const AdShowResult.shown('AdMob interstitial shown.'),
            );
          }
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) {
            completer.complete(
              const AdShowResult.unavailable(
                'AdMob interstitial failed to load.',
              ),
            );
          }
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _interstitialAd?.dispose();
        _interstitialAd = null;
        return const AdShowResult.unavailable(
          'AdMob interstitial load timed out.',
        );
      },
    );
  }

  @override
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement) async {
    final adUnitId = config.rewardedAdUnitIdFor(placement);
    if (adUnitId.isEmpty) {
      return const RewardedAdResult.unavailable(
        'AdMob rewarded ad unit is missing for this placement.',
      );
    }

    final status = await initialize();
    if (!status.isAvailable) return RewardedAdResult.unavailable(status.message);

    final completer = Completer<RewardedAdResult>();
    await gma.RewardedAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      rewardedAdLoadCallback: gma.RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            _completeRewarded(
              completer,
              const RewardedAdResult.unavailable('Ad service was disposed.'),
            );
            return;
          }

          _rewardedAd = ad;
          ad.fullScreenContentCallback = gma.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (shownAd) {
              shownAd.dispose();
              if (identical(_rewardedAd, shownAd)) _rewardedAd = null;
              _completeRewarded(
                completer,
                const RewardedAdResult.dismissed(),
              );
            },
            onAdFailedToShowFullScreenContent: (shownAd, _) {
              shownAd.dispose();
              if (identical(_rewardedAd, shownAd)) _rewardedAd = null;
              _completeRewarded(
                completer,
                const RewardedAdResult.failed(
                  'AdMob rewarded ad failed to show.',
                ),
              );
            },
          );
          ad.show(
            onUserEarnedReward: (_, reward) {
              _completeRewarded(
                completer,
                RewardedAdResult.verified(
                  rewardEventId: _rewardEventId(placement, reward),
                  message: 'AdMob rewarded ad completed.',
                ),
              );
            },
          );
        },
        onAdFailedToLoad: (_) {
          _completeRewarded(
            completer,
            const RewardedAdResult.failed('AdMob rewarded ad failed to load.'),
          );
        },
      ),
    );

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        _rewardedAd?.dispose();
        _rewardedAd = null;
        return const RewardedAdResult.failed('AdMob rewarded ad timed out.');
      },
    );
  }

  void _completeRewarded(
    Completer<RewardedAdResult> completer,
    RewardedAdResult result,
  ) {
    if (!completer.isCompleted) completer.complete(result);
  }

  String _rewardEventId(AdPlacement placement, gma.RewardItem reward) {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    return 'admob:${placement.name}:$timestamp:${reward.amount}:${reward.type}';
  }

  @override
  void dispose() {
    _disposed = true;
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
