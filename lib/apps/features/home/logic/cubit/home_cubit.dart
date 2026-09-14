import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/home_repository.dart';

class HomeCubit extends Cubit<String> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super('there') {
    emit(_repository.getUserDisplayName());
  }
}
