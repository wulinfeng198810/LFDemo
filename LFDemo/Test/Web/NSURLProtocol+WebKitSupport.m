
#import "NSURLProtocol+WebKitSupport.h"
#import <WebKit/WebKit.h>
#import "ACObfuscationHeader.h"
#import "NSString+ACObfuscation.h"

FOUNDATION_STATIC_INLINE Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        //[Orginial]---->'browsingContextController'
        __Obfuscation_Done NSString *str = @"[Obfu]->YnJvd3NpbmdDb250ZXh0Q29udHJvbGxlcg==";
        cls = [[[WKWebView new] valueForKey:[str ac_bian]] class];
    }
    return cls;
}

FOUNDATION_STATIC_INLINE SEL RegisterSchemeSelector() {
//[Orginial]---->'registerSchemeForCustomProtocol:'
    __Obfuscation_Done NSString *method = @"[Obfu]->cmVnaXN0ZXJTY2hlbWVGb3JDdXN0b21Qcm90b2NvbDo=";
    return NSSelectorFromString([method ac_bian]);
}

FOUNDATION_STATIC_INLINE SEL UnregisterSchemeSelector() {
//[Orginial]---->'unregisterSchemeForCustomProtocol:'
    __Obfuscation_Done NSString *method = @"[Obfu]->dW5yZWdpc3RlclNjaGVtZUZvckN1c3RvbVByb3RvY29sOg==";
    return NSSelectorFromString([method ac_bian]);
}

@implementation NSURLProtocol (WebKitSupport)

+ (void)wk_registerScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = RegisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

+ (void)wk_unregisterScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = UnregisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

@end

