
#import "NSString+ACObfuscation.h"

@implementation NSString(ACObfuscation)

- (NSString *)ac_bian;
{
    NSString *marker = @"[Obfu]->";
    if (![self hasPrefix:marker]) {
        return self;
    }
    
    NSRange range = [self rangeOfString:marker];
    NSString *todoString = [self substringFromIndex:range.length];
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:todoString options:0];
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    return base64Decoded;
}

@end

