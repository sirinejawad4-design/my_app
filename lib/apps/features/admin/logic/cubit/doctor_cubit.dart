
import 'dart:async';

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

  // WATCH DOCTORS
  void _watchDoctors() {
    _doctorsSubscription = _repository.watchDoctors().listen(
      (doctors) {
        emit(
          state.copyWith(doctors: doctors, isLoading: false, clearError: true),
        );
      },
      onError: (_) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to load doctors. Please try again.',
          ),
        );
      },
    );
  }

  // ADD DOCTOR
  Future<void> addDoctor({
    required String name,
    required String specialty,
    required double fee,
    String? imageUrl,
  }) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false, clearError: true));

    try {
      await _repository.addDoctor(
        name: name,
        specialty: specialty,
        fee: fee,
        imageUrl: imageUrl,
      );

      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to add doctor. Please try again.',
        ),
      );
    }
  }

  // UPDATE DOCTOR PROFILE
  Future<void> updateDoctor({
    required String doctorId,
    required String name,
    required String specialty,
    required double fee,
    String? imageUrl,
  }) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false, clearError: true));

    try {
      await _repository.updateDoctor(
        doctorId: doctorId,
        name: name,
        specialty: specialty,
        fee: fee,
        imageUrl: imageUrl,
      );

      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update doctor. Please try again.',
        ),
      );
    }
  }

  // UPDATE AVAILABILITY
  Future<bool> updateAvailability({
    required String doctorId,
    required Map<String, bool> workingDays,
    required String startTime,
    required String endTime,
    required int slotDuration,
  }) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false, clearError: true));

    try {
      await _repository.updateAvailability(
        doctorId: doctorId,
        workingDays: workingDays,
        startTime: startTime,
        endTime: endTime,
        slotDuration: slotDuration,
      );

      emit(state.copyWith(isSaving: false, saveSuccess: true));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update availability. Please try again.',
        ),
      );
      return false;
    }
  }

  // ACTIVATE / DEACTIVATE
  Future<void> updateDoctorStatus({
    required String doctorId,
    required bool isActive,
  }) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false, clearError: true));

    try {
      await _repository.updateDoctorStatus(
        doctorId: doctorId,
        isActive: isActive,
      );

      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update doctor status. Please try again.',
        ),
      );
    }
  }

  // CLOSE
  @override
  Future<void> close() {
    _doctorsSubscription?.cancel();
    return super.close();
  }
}