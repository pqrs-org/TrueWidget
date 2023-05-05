// -*- mode: objective-c -*-

@import AppKit;

@interface DeprecatedOpenAtLoginHelperObjc : NSObject

+ (BOOL)registered:(NSURL *)appURL;

+ (void)register:(NSURL *)appURL;
+ (void)unregister:(NSURL *)appURL;

@end
