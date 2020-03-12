//
//  CGHDownloadUtil.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/5.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHDownloadUtil.h"
#import <objc/runtime.h>

@implementation CGHDownloadUtil

+ (NSSet *)getProperties:(Class)clazz {
    unsigned int pCount = 0;
    NSMutableSet *mSet = [NSMutableSet set];
    objc_property_t *properties = class_copyPropertyList(clazz, &pCount);
    for (NSUInteger i = 0; i < pCount; i ++) {
        const char *propertyName = property_getName(properties[i]);
        [mSet addObject:@(propertyName)];
    }
    free(properties);
    return mSet;
}

+ (BOOL)removeItemAtPath:(NSString *)path {
    NSError *error;
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if ([fileManager fileExistsAtPath:path] && ![fileManager removeItemAtPath:path error:&error]) {
        return NO;
    }
    return YES;
}

+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)destPath error:(NSError **)error {
    NSFileManager *manager = NSFileManager.defaultManager;
    NSError *_error;
    if ([manager fileExistsAtPath:destPath] && ![manager removeItemAtPath:destPath error:&_error]) {
        *error = _error;
        return NO;
    }
    
    NSString *destDir = destPath.stringByDeletingLastPathComponent;
    if (![manager fileExistsAtPath:destDir]
        && ![manager createDirectoryAtPath:destDir withIntermediateDirectories:YES attributes:nil error:&_error]) {
        *error = _error;
        return NO;
    }
    
    BOOL ret = [manager moveItemAtPath:srcPath toPath:destPath error:&_error];
    if (!ret) {
        *error = _error;
        return NO;
    }
    return YES;
}

@end
