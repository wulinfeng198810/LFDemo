//
//  CGHContactsUtil.h
//  LFDemo
//
//  Created by wulinfeng on 2020/3/19.
//  Copyright © 2020 lio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 选择联系人
@interface CGHContactsUtil : NSObject
- (void)chooseContact:(UIViewController *)presentingVC noGrantedHandler:(void(^)(void))noGrantedHandler cancelHandler:(void(^)(void))cancelHandler completeHandler:(void(^)(NSDictionary *contact))completeHandler;

- (void)addNewContact:(NSDictionary *)contact presentingVC:(UIViewController *)presentingVC noGrantedHandler:(void (^)(void))noGrantedHandler cancelHandler:(void (^)(void))cancelHandler completeHandler:(void (^)(void))completeHandler;

- (void)editContact:(UIViewController *)presentingVC noGrantedHandler:(void (^)(void))noGrantedHandler cancelHandler:(nonnull void (^)(void))cancelHandler completeHandler:(nonnull void (^)(void))completeHandler;
@end

NS_ASSUME_NONNULL_END
