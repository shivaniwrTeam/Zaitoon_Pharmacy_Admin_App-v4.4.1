import 'package:flutter_bloc/flutter_bloc.dart';
import '../Screens/Home.dart';
import 'String.dart';

abstract class FetchCitiesState {}

class FetchCitiesInitial extends FetchCitiesState {}

class FetchCitiesInInProgress extends FetchCitiesState {}

class FetchCitiesSuccess extends FetchCitiesState {
  final List<Map<String, dynamic>> cities;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int offset;
  final int total;
  FetchCitiesSuccess({
    required this.cities,
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.offset,
    required this.total,
  });
  FetchCitiesSuccess copyWith({
    List<Map<String, dynamic>>? cities,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? offset,
    int? total,
  }) {
    return FetchCitiesSuccess(
      cities: cities ?? this.cities,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchCitiesFail extends FetchCitiesState {
  final dynamic error;
  FetchCitiesFail(this.error);
}

class FetchCitiesCubit extends Cubit<FetchCitiesState> {
  FetchCitiesCubit() : super(FetchCitiesInitial());
  fetch({String? search}) async {
    try {
      emit(FetchCitiesInInProgress());
      final response = await apiBaseHelper.postAPICall(getCitiesApi, {
        if (search != null) "search": search,
      });
      emit(FetchCitiesSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          offset: 0,
          total: int.tryParse(response?['total'] ?? "0") ?? 0,
          cities: List<Map<String, dynamic>>.from(response['data']),),);
    } catch (e, st) {
      emit(FetchCitiesFail(st));
    }
  }

  Future<void> fetchMore() async {
    try {
      if (state is FetchCitiesSuccess) {
        if ((state as FetchCitiesSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCitiesSuccess).copyWith(isLoadingMore: true));
        final Map result = await apiBaseHelper.postAPICall(getCitiesApi,
            {"offset": (state as FetchCitiesSuccess).cities.length.toString()},);
        final FetchCitiesSuccess citiesstate = state as FetchCitiesSuccess;
        citiesstate.cities
            .addAll(List<Map<String, dynamic>>.from(result['data']));
        emit(FetchCitiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            cities: citiesstate.cities,
            offset: (state as FetchCitiesSuccess).cities.length,
            total: int.tryParse(result['total']) ?? 0,),);
      }
    } catch (e) {
      emit((state as FetchCitiesSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true),);
    }
  }

  bool hasMoreData() {
    if (state is FetchCitiesSuccess) {
      return (state as FetchCitiesSuccess).cities.length <
          (state as FetchCitiesSuccess).total;
    }
    return false;
  }
}
