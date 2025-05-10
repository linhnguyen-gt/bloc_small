// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'count_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Increment {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Increment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Increment()';
}


}

/// @nodoc
class $IncrementCopyWith<$Res>  {
$IncrementCopyWith(Increment _, $Res Function(Increment) __);
}


/// @nodoc


class _Increment extends Increment {
  const _Increment(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Increment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Increment()';
}


}




/// @nodoc
mixin _$Decrement {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Decrement);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Decrement()';
}


}

/// @nodoc
class $DecrementCopyWith<$Res>  {
$DecrementCopyWith(Decrement _, $Res Function(Decrement) __);
}


/// @nodoc


class _Decrement extends Decrement {
  const _Decrement(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Decrement);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Decrement()';
}


}




/// @nodoc
mixin _$CountState {

 int get count;
/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountStateCopyWith<CountState> get copyWith => _$CountStateCopyWithImpl<CountState>(this as CountState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountState&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'CountState(count: $count)';
}


}

/// @nodoc
abstract mixin class $CountStateCopyWith<$Res>  {
  factory $CountStateCopyWith(CountState value, $Res Function(CountState) _then) = _$CountStateCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$CountStateCopyWithImpl<$Res>
    implements $CountStateCopyWith<$Res> {
  _$CountStateCopyWithImpl(this._self, this._then);

  final CountState _self;
  final $Res Function(CountState) _then;

/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _Initial extends CountState {
  const _Initial({this.count = 0}): super._();
  

@override@JsonKey() final  int count;

/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitialCopyWith<_Initial> get copyWith => __$InitialCopyWithImpl<_Initial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'CountState.initial(count: $count)';
}


}

/// @nodoc
abstract mixin class _$InitialCopyWith<$Res> implements $CountStateCopyWith<$Res> {
  factory _$InitialCopyWith(_Initial value, $Res Function(_Initial) _then) = __$InitialCopyWithImpl;
@override @useResult
$Res call({
 int count
});




}
/// @nodoc
class __$InitialCopyWithImpl<$Res>
    implements _$InitialCopyWith<$Res> {
  __$InitialCopyWithImpl(this._self, this._then);

  final _Initial _self;
  final $Res Function(_Initial) _then;

/// Create a copy of CountState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_Initial(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
