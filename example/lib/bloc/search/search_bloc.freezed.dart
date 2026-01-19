// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateQuery {

 String get query;
/// Create a copy of UpdateQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateQueryCopyWith<UpdateQuery> get copyWith => _$UpdateQueryCopyWithImpl<UpdateQuery>(this as UpdateQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateQuery&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'UpdateQuery(query: $query)';
}


}

/// @nodoc
abstract mixin class $UpdateQueryCopyWith<$Res>  {
  factory $UpdateQueryCopyWith(UpdateQuery value, $Res Function(UpdateQuery) _then) = _$UpdateQueryCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$UpdateQueryCopyWithImpl<$Res>
    implements $UpdateQueryCopyWith<$Res> {
  _$UpdateQueryCopyWithImpl(this._self, this._then);

  final UpdateQuery _self;
  final $Res Function(UpdateQuery) _then;

/// Create a copy of UpdateQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateQuery].
extension UpdateQueryPatterns on UpdateQuery {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateQuery() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateQuery value)  $default,){
final _that = this;
switch (_that) {
case _UpdateQuery():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateQuery value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateQuery() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateQuery() when $default != null:
return $default(_that.query);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query)  $default,) {final _that = this;
switch (_that) {
case _UpdateQuery():
return $default(_that.query);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query)?  $default,) {final _that = this;
switch (_that) {
case _UpdateQuery() when $default != null:
return $default(_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateQuery extends UpdateQuery {
  const _UpdateQuery(this.query): super._();
  

@override final  String query;

/// Create a copy of UpdateQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateQueryCopyWith<_UpdateQuery> get copyWith => __$UpdateQueryCopyWithImpl<_UpdateQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateQuery&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'UpdateQuery(query: $query)';
}


}

/// @nodoc
abstract mixin class _$UpdateQueryCopyWith<$Res> implements $UpdateQueryCopyWith<$Res> {
  factory _$UpdateQueryCopyWith(_UpdateQuery value, $Res Function(_UpdateQuery) _then) = __$UpdateQueryCopyWithImpl;
@override @useResult
$Res call({
 String query
});




}
/// @nodoc
class __$UpdateQueryCopyWithImpl<$Res>
    implements _$UpdateQueryCopyWith<$Res> {
  __$UpdateQueryCopyWithImpl(this._self, this._then);

  final _UpdateQuery _self;
  final $Res Function(_UpdateQuery) _then;

/// Create a copy of UpdateQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_UpdateQuery(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$UpdateResults {

 List<String> get results;
/// Create a copy of UpdateResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateResultsCopyWith<UpdateResults> get copyWith => _$UpdateResultsCopyWithImpl<UpdateResults>(this as UpdateResults, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateResults&&const DeepCollectionEquality().equals(other.results, results));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results));

@override
String toString() {
  return 'UpdateResults(results: $results)';
}


}

/// @nodoc
abstract mixin class $UpdateResultsCopyWith<$Res>  {
  factory $UpdateResultsCopyWith(UpdateResults value, $Res Function(UpdateResults) _then) = _$UpdateResultsCopyWithImpl;
@useResult
$Res call({
 List<String> results
});




}
/// @nodoc
class _$UpdateResultsCopyWithImpl<$Res>
    implements $UpdateResultsCopyWith<$Res> {
  _$UpdateResultsCopyWithImpl(this._self, this._then);

  final UpdateResults _self;
  final $Res Function(UpdateResults) _then;

/// Create a copy of UpdateResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateResults].
extension UpdateResultsPatterns on UpdateResults {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateResults() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateResults value)  $default,){
final _that = this;
switch (_that) {
case _UpdateResults():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateResults value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateResults() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateResults() when $default != null:
return $default(_that.results);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> results)  $default,) {final _that = this;
switch (_that) {
case _UpdateResults():
return $default(_that.results);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> results)?  $default,) {final _that = this;
switch (_that) {
case _UpdateResults() when $default != null:
return $default(_that.results);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateResults extends UpdateResults {
  const _UpdateResults(final  List<String> results): _results = results,super._();
  

 final  List<String> _results;
@override List<String> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of UpdateResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateResultsCopyWith<_UpdateResults> get copyWith => __$UpdateResultsCopyWithImpl<_UpdateResults>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateResults&&const DeepCollectionEquality().equals(other._results, _results));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'UpdateResults(results: $results)';
}


}

/// @nodoc
abstract mixin class _$UpdateResultsCopyWith<$Res> implements $UpdateResultsCopyWith<$Res> {
  factory _$UpdateResultsCopyWith(_UpdateResults value, $Res Function(_UpdateResults) _then) = __$UpdateResultsCopyWithImpl;
@override @useResult
$Res call({
 List<String> results
});




}
/// @nodoc
class __$UpdateResultsCopyWithImpl<$Res>
    implements _$UpdateResultsCopyWith<$Res> {
  __$UpdateResultsCopyWithImpl(this._self, this._then);

  final _UpdateResults _self;
  final $Res Function(_UpdateResults) _then;

/// Create a copy of UpdateResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,}) {
  return _then(_UpdateResults(
null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$SearchError {

 String get message;
/// Create a copy of SearchError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchErrorCopyWith<SearchError> get copyWith => _$SearchErrorCopyWithImpl<SearchError>(this as SearchError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchError(message: $message)';
}


}

/// @nodoc
abstract mixin class $SearchErrorCopyWith<$Res>  {
  factory $SearchErrorCopyWith(SearchError value, $Res Function(SearchError) _then) = _$SearchErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SearchErrorCopyWithImpl<$Res>
    implements $SearchErrorCopyWith<$Res> {
  _$SearchErrorCopyWithImpl(this._self, this._then);

  final SearchError _self;
  final $Res Function(SearchError) _then;

/// Create a copy of SearchError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchError].
extension SearchErrorPatterns on SearchError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchError() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchError value)  $default,){
final _that = this;
switch (_that) {
case _SearchError():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchError value)?  $default,){
final _that = this;
switch (_that) {
case _SearchError() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchError() when $default != null:
return $default(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _SearchError():
return $default(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _SearchError() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _SearchError extends SearchError {
  const _SearchError(this.message): super._();
  

@override final  String message;

/// Create a copy of SearchError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchErrorCopyWith<_SearchError> get copyWith => __$SearchErrorCopyWithImpl<_SearchError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$SearchErrorCopyWith<$Res> implements $SearchErrorCopyWith<$Res> {
  factory _$SearchErrorCopyWith(_SearchError value, $Res Function(_SearchError) _then) = __$SearchErrorCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$SearchErrorCopyWithImpl<$Res>
    implements _$SearchErrorCopyWith<$Res> {
  __$SearchErrorCopyWithImpl(this._self, this._then);

  final _SearchError _self;
  final $Res Function(_SearchError) _then;

/// Create a copy of SearchError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_SearchError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SearchState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SearchState()';
}


}

/// @nodoc
class $SearchStateCopyWith<$Res>  {
$SearchStateCopyWith(SearchState _, $Res Function(SearchState) __);
}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( Loaded value)?  loaded,TResult Function( Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case Loaded() when loaded != null:
return loaded(_that);case Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( Loaded value)  loaded,required TResult Function( Error value)  error,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case Loaded():
return loaded(_that);case Error():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( Loaded value)?  loaded,TResult? Function( Error value)?  error,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case Loaded() when loaded != null:
return loaded(_that);case Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( List<String> results)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case Loaded() when loaded != null:
return loaded(_that.results);case Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( List<String> results)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case Loaded():
return loaded(_that.results);case Error():
return error(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( List<String> results)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case Loaded() when loaded != null:
return loaded(_that.results);case Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class Initial extends SearchState {
  const Initial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SearchState.initial()';
}


}




/// @nodoc


class Loaded extends SearchState {
  const Loaded(final  List<String> results): _results = results,super._();
  

 final  List<String> _results;
 List<String> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadedCopyWith<Loaded> get copyWith => _$LoadedCopyWithImpl<Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loaded&&const DeepCollectionEquality().equals(other._results, _results));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return 'SearchState.loaded(results: $results)';
}


}

/// @nodoc
abstract mixin class $LoadedCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory $LoadedCopyWith(Loaded value, $Res Function(Loaded) _then) = _$LoadedCopyWithImpl;
@useResult
$Res call({
 List<String> results
});




}
/// @nodoc
class _$LoadedCopyWithImpl<$Res>
    implements $LoadedCopyWith<$Res> {
  _$LoadedCopyWithImpl(this._self, this._then);

  final Loaded _self;
  final $Res Function(Loaded) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? results = null,}) {
  return _then(Loaded(
null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class Error extends SearchState {
  const Error(this.message): super._();
  

 final  String message;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorCopyWith<Error> get copyWith => _$ErrorCopyWithImpl<Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SearchState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory $ErrorCopyWith(Error value, $Res Function(Error) _then) = _$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ErrorCopyWithImpl<$Res>
    implements $ErrorCopyWith<$Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error _self;
  final $Res Function(Error) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
