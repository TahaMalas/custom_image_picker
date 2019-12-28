#import "CustomImagePickerPlugin.h"
#if __has_include(<custom_image_picker/custom_image_picker-Swift.h>)
#import <custom_image_picker/custom_image_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "custom_image_picker-Swift.h"
#endif

@implementation CustomImagePickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCustomImagePickerPlugin registerWithRegistrar:registrar];
}
@end
