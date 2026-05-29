import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';

class MonetizationCubit extends Cubit<MonetizationState> {
  final AdService? _adService;

  MonetizationCubit({AdService? adService})
      : _adService = adService,
        super(const MonetizationState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      await _adService?.initialize();
      emit(state.copyWith(loading: false, initialized: true));
    } catch (_) {
      emit(state.copyWith(loading: false, initialized: true));
    }
  }

  void setPremium(bool isPremium) {
    emit(state.copyWith(isPremium: isPremium));
  }

  void showInterstitialAd() {
    _adService?.showInterstitial();
  }
}

class MonetizationState {
  final bool loading;
  final bool initialized;
  final bool isPremium;
  const MonetizationState({this.loading = false, this.initialized = false, this.isPremium = false});

  bool get showAds => !isPremium && initialized;

  MonetizationState copyWith({bool? loading, bool? initialized, bool? isPremium}) =>
      MonetizationState(loading: loading ?? this.loading, initialized: initialized ?? this.initialized, isPremium: isPremium ?? this.isPremium);
}
