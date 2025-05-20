/// A base class for all Bloc events in the application.
///
/// This abstract class serves as a foundation for creating specific event classes
/// that can be used with Blocs. All custom event classes should extend this class.
///
/// The const constructor allows for efficient instantiation of event objects.
///
/// Example with regular class:
/// ```dart
/// class MySpecificEvent extends MainBlocEvent {
///   final String someData;
///
///   const MySpecificEvent(this.someData);
/// }
///
/// // Using the event
/// bloc.add(MySpecificEvent('Some data'));
/// ```
///
/// Example with Freezed 3.0.0:
/// ```dart
/// import 'package:freezed_annotation/freezed_annotation.dart';
///
/// part 'my_event.freezed.dart';
///
/// @freezed
/// sealed class MyEvent extends MainBlocEvent with _$MyEvent {
///   const MyEvent._(); // Required private constructor
///
///   const factory MyEvent.started() = Started;
///   const factory MyEvent.dataLoaded(String data) = DataLoaded;
/// }
///
/// // Using the event with pattern matching
/// void handleEvent(MyEvent event) {
///   final result = switch (event) {
///     Started() => 'Starting...',
///     DataLoaded(:final data) => 'Data: $data',
///   };
/// }
/// ```
///
/// Note: When using with Freezed 3.0.0+:
/// 1. Use `sealed` keyword for pattern matching with fixed number of subtypes
/// 2. Use `abstract` keyword if the class can be extended/implemented
/// 3. Extend MainBlocEvent instead of implementing it
/// 4. Always include a private constructor when using extends/with
/// 5. Use Dart's built-in pattern matching instead of .when/.map methods
abstract class MainBlocEvent {
  const MainBlocEvent();
}
