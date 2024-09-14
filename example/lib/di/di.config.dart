// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bloc_small/common/common_bloc.dart' as _i423;
import 'package:bloc_small_example/bloc/count_bloc.dart' as _i517;
import 'package:bloc_small_example/di/di.dart' as _i994;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.factory<_i517.CountBloc>(() => _i517.CountBloc());
    gh.factory<_i423.CommonBloc>(() => registerModule.commonBloc);
    return this;
  }
}

class _$RegisterModule extends _i994.RegisterModule {}
