import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/core/bloc/main_bloc.dart';

extension BlocContextX on BuildContext {
  B bloc<B extends MainBloc>() => BlocProvider.of<B>(this);
  B read<B extends MainBloc>() => ReadContext(this).read<B>();
  B watch<B extends MainBloc>() => WatchContext(this).watch<B>();
}
