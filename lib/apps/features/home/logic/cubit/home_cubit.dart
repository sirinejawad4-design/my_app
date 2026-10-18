import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/home_repository.dart';
import '../../../admin/data/models/doctor.dart';

class HomeState {
  final String userName;
  final List<Doctor> doctors;
  final bool isLoading;

  const HomeState({
    required this.userName,
    required this.doctors,
    required this.isLoading,
  });

  HomeState copyWith({
    String? userName,
    List<Doctor>? doctors,
    bool? isLoading,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  StreamSubscription<List<Doctor>>? _doctorsSubscription;

  HomeCubit(this._repository)
    : super(const HomeState(userName: 'there', doctors: [], isLoading: true)) {
    _loadHome();
  }

  void _loadHome() {
    emit(state.copyWith(userName: _repository.getUserDisplayName()));

    _doctorsSubscription = _repository.watchActiveDoctors().listen(
      (doctors) {
        emit(state.copyWith(doctors: doctors, isLoading: false));
      },
      onError: (error, stackTrace) {
        emit(state.copyWith(doctors: [], isLoading: false));
      },
    );
  }

  List<Doctor> get popularDoctors {
    return _repository.getPopularDoctors(state.doctors);
  }

  List<Doctor> get topRatedDoctors {
    return _repository.getTopRatedDoctors(state.doctors);
  }

  @override
  Future<void> close() async {
    await _doctorsSubscription?.cancel();
    return super.close();
  }
}
