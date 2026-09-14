import 'package:equatable/equatable.dart';
import '../../data/models/doctor.dart';

class DoctorState extends Equatable {
  final List<Doctor> doctors;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const DoctorState({
    this.doctors = const [],
    this.isLoading = true,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  DoctorState copyWith({
    List<Doctor>? doctors,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorState(
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        doctors,
        isLoading,
        isSaving,
        saveSuccess,
        errorMessage,
      ];
}
