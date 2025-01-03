/// A base class for all Bloc events in the application.
///
/// This abstract class serves as a foundation for creating specific event classes
/// that can be used with Blocs. All custom event classes should extend this class.
///
/// The const constructor allows for efficient instantiation of event objects.
///
/// Usage:
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
/// Or for freezed:
/// ```dart
/// import 'package:freezed_annotation/freezed_annotation.dart';
///
/// part 'my_event.freezed.dart';
///
/// @freezed
/// class MyEvent with _$MyEvent implements MainBlocEvent {
///   const factory MyEvent.started() = _Started;
///   const factory MyEvent.dataLoaded(String data) = _DataLoaded;
/// }
///
/// // Using the event
/// bloc.add(const MyEvent.started());
/// bloc.add(const MyEvent.dataLoaded('Some data'));
/// ```
abstract class MainBlocEvent {
  const MainBlocEvent();
}
