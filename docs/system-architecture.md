# System Architecture

## Overview

`bloc_small` is built on top of `flutter_bloc` and provides a layered architecture that simplifies state management while maintaining separation of concerns.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (BaseBlocPageState, BaseCubitPageState, Widgets)      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    State Management Layer                │
│  (MainBloc, MainCubit, CommonBloc, BaseDelegate)       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      Core Layer                         │
│  (Error Handling, DI, Navigation, ReactiveSubject)      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Foundation Layer                       │
│  (flutter_bloc, GetIt, Injectable, RxDart, auto_route)  │
└─────────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. Presentation Layer

#### Widget Hierarchy

```
Widget
  ├── BaseBlocPage<B> (StatelessWidget)
  │   └── Uses BasePageStatelessDelegate
  │
  ├── BaseCubitPage<C> (StatelessWidget)
  │   └── Uses BasePageStatelessDelegate
  │
  └── StatefulWidget
      ├── BaseBlocPageState<T, B>
      │   └── Uses BasePageDelegate
      │
      └── BaseCubitPageState<T, C>
          └── Uses BasePageDelegate
```

#### Responsibilities
- UI rendering
- User interaction handling
- Loading overlay management
- Navigation triggering

### 2. State Management Layer

#### BLoC Architecture

```
MainBlocEvent (Base)
    │
    ├── CommonEvent
    │   └── SetComponentLoading
    │
    └── [User Events]
        └── Extend MainBlocEvent

MainBlocState (Base)
    │
    ├── CommonState
    │   └── Manages loadingStates Map
    │
    └── [User States]
        └── Extend MainBlocState

MainBloc<E, S>
    │
    ├── CommonBloc (Singleton)
    │   └── Manages global loading states
    │
    └── [User BLoCs]
        └── Extend MainBloc
```

#### Cubit Architecture

```
MainCubit<S>
    │
    └── [User Cubits]
        └── Extend MainCubit
```

#### BaseDelegate Mixin

Provides shared functionality:
- Loading state management
- Error handling (`catchError`)
- Navigation access
- Common bloc integration

### 3. Core Layer

#### Error Handling System

```
Exception (Base)
    ├── NetworkException
    ├── ValidationException
    └── TimeoutException

Error Handler Mixins
    ├── BlocErrorHandlerMixin
    │   └── Used with MainBloc
    │
    └── CubitErrorHandlerMixin
        └── Used with MainCubit

Error Handling Flow
    └── blocCatch / cubitCatch
        ├── Show loading
        ├── Execute actions
        ├── Handle errors
        └── Hide loading
```

#### Dependency Injection System

```
GetIt (Service Locator)
    ├── CoreModule
    │   └── CommonBloc (Singleton)
    │
    ├── AppRouter (LazySingleton)
    │   └── BaseAppRouter implementation
    │
    ├── AppNavigator (LazySingleton)
    │   └── Wraps AppRouter
    │
    └── [User Dependencies]
        └── Registered via @injectable
```

#### Navigation System

```
INavigator (Interface)
    │
    └── AppNavigator (Implementation)
        ├── Uses BaseAppRouter
        ├── Type-safe navigation
        └── Optional logging

BaseAppRouter
    └── Extends auto_route Router
        └── Provides navigation methods
```

#### Reactive Programming

```
ReactiveSubject<T>
    ├── Wraps BehaviorSubject (default)
    ├── Wraps PublishSubject (broadcast)
    │
    └── Stream Transformations
        ├── map, where, switchMap
        ├── debounceTime, throttleTime
        ├── distinct, scan
        ├── retry, onErrorResumeNext
        └── share, shareReplay, buffer
```

## Data Flow

### BLoC Pattern Flow

```
User Action
    │
    ▼
Event (MainBlocEvent)
    │
    ▼
MainBloc.add(Event)
    │
    ▼
Event Handler (_onEvent)
    │
    ├── blocCatch
    │   ├── showLoading()
    │   ├── Execute async logic
    │   ├── Handle errors
    │   └── hideLoading()
    │
    └── emit(NewState)
        │
        ▼
State (MainBlocState)
    │
    ▼
BlocBuilder / BlocListener
    │
    ▼
UI Update
```

### Cubit Pattern Flow

```
User Action
    │
    ▼
Cubit Method Call
    │
    ├── cubitCatch
    │   ├── showLoading()
    │   ├── Execute async logic
    │   ├── Handle errors
    │   └── hideLoading()
    │
    └── emit(NewState)
        │
        ▼
State (MainBlocState)
    │
    ▼
BlocBuilder / BlocListener
    │
    ▼
UI Update
```

### Loading State Flow

```
Component Action
    │
    ▼
showLoading(key: 'myKey')
    │
    ▼
CommonBloc.add(SetComponentLoading(key: 'myKey', isLoading: true))
    │
    ▼
CommonState.loadingStates['myKey'] = true
    │
    ▼
BlocBuilder<CommonBloc, CommonState>
    │
    ▼
buildLoadingOverlay() detects loading
    │
    ▼
LoadingIndicator displayed
    │
    ▼
Action completes
    │
    ▼
hideLoading(key: 'myKey')
    │
    ▼
CommonBloc.add(SetComponentLoading(key: 'myKey', isLoading: false))
    │
    ▼
CommonState.loadingStates['myKey'] = false
    │
    ▼
LoadingIndicator hidden
```

## Integration Points

### 1. Dependency Injection Integration

```dart
@InjectableInit()
void configureInjectionApp() {
  // 1. Register core dependencies
  getIt.registerCore();
  
  // 2. Register router (optional)
  getIt.registerAppRouter<AppRouter>(AppRouter());
  
  // 3. Register app dependencies
  getIt.init();
}
```

### 2. Navigation Integration

```dart
@AutoRouterConfig()
@LazySingleton()
class AppRouter extends BaseAppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
  ];
}
```

### 3. Widget Integration

```dart
// StatefulWidget with BLoC
class MyPageState extends BaseBlocPageState<MyPage, MyBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      child: Scaffold(/* ... */),
    );
  }
}

// StatelessWidget with BLoC
class MyPage extends BaseBlocPage<MyBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      context,
      child: Scaffold(/* ... */),
    );
  }
}
```

## Extension Points

### 1. Custom Error Handling

```dart
class MyBloc extends MainBloc<MyEvent, MyState> 
    with BlocErrorHandlerMixin {
  @override
  Future<void> handleError(Object error, StackTrace stackTrace) async {
    super.handleError(error, stackTrace);
    // Custom error handling
  }
}
```

### 2. Custom Navigation

Implement `INavigator` interface:
```dart
class CustomNavigator implements INavigator {
  // Implement navigation methods
}
```

### 3. Custom Loading Widget

```dart
buildLoadingOverlay(
  child: content,
  loadingWidget: CustomLoadingWidget(),
)
```

## Performance Considerations

### 1. State Management
- States are immutable (Freezed)
- Only necessary rebuilds occur
- Efficient state comparison

### 2. Loading States
- Component-specific loading keys prevent unnecessary rebuilds
- Weak references for CommonBloc to prevent memory leaks

### 3. Navigation
- Lazy singleton for router
- Optional logging to reduce overhead

### 4. ReactiveSubject
- Proper disposal prevents memory leaks
- Managed subscriptions for cleanup

## Security Considerations

1. **Error Information**: Error messages don't expose sensitive data
2. **Navigation**: Type-safe navigation prevents route injection
3. **Dependency Injection**: Proper scoping prevents unauthorized access

## Testing Architecture

### Unit Tests
- Test BLoCs/Cubits in isolation
- Mock dependencies
- Test state transitions

### Widget Tests
- Test widget rendering
- Test user interactions
- Test state updates

### Integration Tests
- Test complete flows
- Test navigation
- Test error handling

## Migration Path

### From flutter_bloc to bloc_small

1. Replace `Bloc` with `MainBloc`
2. Replace `Cubit` with `MainCubit`
3. Use `BaseBlocPageState` or `BaseCubitPageState`
4. Use `blocCatch` or `cubitCatch` for error handling
5. Register dependencies via `registerCore()`

## Example Application

A comprehensive example application is provided in the `example/` directory that demonstrates all architectural patterns and features:

- **Complete Setup**: Shows proper DI, navigation, and app initialization
- **BLoC Examples**: Counter and search implementations
- **Cubit Examples**: Simplified counter implementation
- **ReactiveSubject**: 12+ real-world use cases
- **Best Practices**: Follows all architectural guidelines

See [example/README.md](../example/README.md) for detailed documentation and code examples.
