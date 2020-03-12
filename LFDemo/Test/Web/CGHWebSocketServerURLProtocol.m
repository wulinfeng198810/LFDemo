//
//  CGHWebSocketServerURLProtocol.m
//  WKWebVIewHybridDemo
//
//  Created by wulinfeng on 2019/8/15.
//  Copyright © 2019 shuoyu liu. All rights reserved.
//

#import "CGHWebSocketServerURLProtocol.h"
#import "YYKit.h"
#import <MobileCoreServices/MobileCoreServices.h>

static NSString *const CGHWebSocketServerURLProtocol_Intercept_calibration = @"file:///calibration";
static NSString *const CGHWebSocketServerURLProtocol_Intercept_calibration_toHttp = @"http://calibration";

static NSString *const CGHWebSocketServerURLProtocol_Intercept_static= @"file:///static";

static NSString *const CGHWebSocketServerURLProtocol_Intercept_apihelper_assdk = @"file:///apihelper/assdk";
static NSString *const CGHWebSocketServerURLProtocol_Intercept_apihelper_assdk_toHttp = @"http://apihelper/assdk";

static NSString* const kCGHWebSocketServerURLProtocolKey = @"kCGHWebSocketServerURLProtocolKey";

@interface CGHWebSocketServerURLProtocol ()<NSURLSessionDelegate>
@property (nonnull,strong) NSURLSessionDataTask *task;
@end

@implementation CGHWebSocketServerURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *absoluteString = request.URL.absoluteString;
    if ([absoluteString hasPrefix:CGHWebSocketServerURLProtocol_Intercept_static]) {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:kCGHWebSocketServerURLProtocolKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    
    //request截取重定向
    NSString *absoluteString = request.URL.absoluteString;
    if (([absoluteString containsString:CGHWebSocketServerURLProtocol_Intercept_apihelper_assdk] | [absoluteString hasPrefix:CGHWebSocketServerURLProtocol_Intercept_calibration])
        && [absoluteString hasPrefix:@"file://"]) {
        absoluteString = [@"http://" stringByAppendingString:[absoluteString substringFromIndex:@"file:///".length]];
        mutableReqeust = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:absoluteString]];
    }
    
    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [self.request mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:kCGHWebSocketServerURLProtocolKey inRequest:mutableReqeust];
    
    NSString *absoluteString = self.request.URL.absoluteString;
    absoluteString = [absoluteString stringByURLDecode];
    if ([absoluteString hasPrefix:CGHWebSocketServerURLProtocol_Intercept_static]) {
        [self intercept_static:absoluteString];
        
    } else {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }
}

- (void)stopLoading {
    if (self.task) {
        [self.task  cancel];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

#pragma mark - intercept
- (void)intercept_static:(NSString *)originPath {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"adver.png" ofType:nil];
    NSString *MIMEType = [self getMIMETypeForLocalFilePath:filePath];
    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL fileURLWithPath:filePath] options:YYWebImageOptionIgnoreDiskCache progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        YYImage *_image = (YYImage *)image;
        NSData *data = _image.animatedImageData;
        if (data) {
            NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:MIMEType expectedContentLength:data.length textEncodingName:nil];
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        } else {
            NSError *error = [NSError errorWithDomain:@"" code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"file not found at path: %@", originPath]}];
            [self.client URLProtocol:self didFailWithError:error];
        }
    }];
}

//获取本地文件的MIMEType
- (NSString *)getMIMETypeForLocalFilePath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) { return nil; }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

@end
