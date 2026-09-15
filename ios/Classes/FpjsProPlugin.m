#import "FpjsProPlugin.h"
#if __has_include(<fpjs_pro_plugin/fpjs_pro_plugin-Swift.h>)
#import <fpjs_pro_plugin/fpjs_pro_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fpjs_pro_plugin-Swift.h"
#endif

@implementation FpjsProPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFpjsProPlugin registerWithRegistrar:registrar];
}
@end
