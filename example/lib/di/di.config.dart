// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bloc_small/common/common_bloc.dart' as _i423;
import 'package:bloc_small_example/bloc/count/count_bloc.dart' as _i310;
import 'package:bloc_small_example/bloc/search/search_bloc.dart' as _i127;
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
    gh.factory<_i423.CommonBloc>(() => registerModule.commonBloc);
    gh.factory<_i310.CountBloc>(() => _i310.CountBloc());
    gh.factory<_i127.SearchBloc>(() => _i127.SearchBloc());
    return this;
  }
}

class _$RegisterModule extends _i994.RegisterModule {}
