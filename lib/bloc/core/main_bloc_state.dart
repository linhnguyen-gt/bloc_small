/// A base class for all Bloc states in the application.
///
/// This abstract class serves as a foundation for creating specific state classes
/// that can be used with Blocs. All custom state classes should extend this class.
///
/// The const constructor allows for efficient instantiation of state objects.
///
/// Example with regular class:
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
/// Example with Freezed 3.0.0:
/// ```dart
/// import 'package:freezed_annotation/freezed_annotation.dart';
///
/// part 'my_state.freezed.dart';
///
/// @freezed
/// sealed class MyState extends MainBlocState with _$MyState {
///   const factory MyState.initial() = _Initial;
///   const factory MyState.loading() = _Loading;
///   const factory MyState.loaded(String data) = _Loaded;
/// }
///
/// // Using the state with pattern matching
/// final state = MyState.loaded('data');
/// final result = switch (state) {
///   Initial() => 'Initial State',
///   Loading() => 'Loading State',
///   Loaded(:final data) => 'Loaded: $data',
/// };
/// ```
///
/// Note: When using with Freezed 3.0.0+:
/// 1. Use `sealed` keyword for pattern matching with fixed number of subtypes
/// 2. Use `abstract` keyword if the class can be extended/implemented
/// 3. Extend MainBlocState instead of implementing it
/// 4. Use Dart's built-in pattern matching instead of .when/.map methods
abstract class MainBlocState {
  const MainBlocState();
}
