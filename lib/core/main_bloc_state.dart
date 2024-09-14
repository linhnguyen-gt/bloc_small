/// A base class for all Bloc states in the application.
///
/// This abstract class serves as a foundation for creating specific state classes
/// that can be used with Blocs. All custom state classes should extend this class.
///
/// The const constructor allows for efficient instantiation of state objects.
///
/// Usage:
/// ```dart
/// class MySpecificState extends MainBlocState {
///   final String someData;
///
///   const MySpecificState(this.someData);
/// }
///
/// // Using the state
/// emit(MySpecificState('Some data'));
/// ```
///
/// Or for freezed:
/// ```dart
/// import 'package:freezed_annotation/freezed_annotation.dart';
///
/// part 'my_state.freezed.dart';
///
/// @freezed
/// class MyState with _$MyState implements MainBlocState {
///   const factory MyState.initial() = _Initial;
///   const factory MyState.loading() = _Loading;
///   const factory MyState.loaded(String data) = _Loaded;
/// }
///
/// // Using the state
/// emit(const MyState.initial());
/// emit(const MyState.loading());
/// emit(const MyState.loaded('Some data'));
/// ```
abstract class MainBlocState {
  const MainBlocState();
}
