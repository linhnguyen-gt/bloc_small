#import "BlocLitePlugin.h"
#if __has_include(<bloc_lite/bloc_lite-Swift.h>)
#import <bloc_lite/bloc_lite-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bloc_lite-Swift.h"
#endif

@implementation BlocLitePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBlocLitePlugin registerWithRegistrar:registrar];
}
@end
