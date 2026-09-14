import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/doctor.dart';
import '../../data/repositories/doctor_repository.dart';
import 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _repository;
  StreamSubscription<List<Doctor>>? _doctorsSubscription;

  DoctorCubit(this._repository) : super(const DoctorState()) {
    _watchDoctors();
  }

  void _watchDoctors() {
    _doctorsSubscription = _repository.watchDoctors().listen(
      (doctors) => emit(state.copyWith(
        doctors: doctors,
        isLoading: false,
        clearError: true,
      )),
      onError: (_) => emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load doctors. Please try again.',
      )),
    );
  }

  Future<void> addDoctor({
    required String name,
    required String specialty,
    File? image,
  }) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false, clearError: true));

    try {
      await _repository.addDoctor(
        name: name,
        specialty: specialty,
        image: image,
      );
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to add doctor. Please try again.',
      ));
    }
  }

  @override
  Future<void> close() {
    _doctorsSubscription?.cancel();
    return super.close();
  }
}
