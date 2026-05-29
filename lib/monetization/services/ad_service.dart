abstract class AdService {
  Future<void> initialize();
  void dispose();
  void showInterstitial();
  void showBanner();
  void hideBanner();
}

class NoOpAdService implements AdService {
  @override
  Future<void> initialize() async {}
  @override
  void dispose() {}
  @override
  void showInterstitial() {}
  @override
  void showBanner() {}
  @override
  void hideBanner() {}
}
