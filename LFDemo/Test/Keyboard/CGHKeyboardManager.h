//
//  CGHKeyboardManager.h
//  LFDemo
//
//  Created by wulinfeng on 2020/4/23.
//  Copyright © 2020 lio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHKeyboardManager : NSObject

- (void)showKeyboard:(UIView *)onView args:(NSDictionary *)args;

- (void)hideKeyboard;

@end

NS_ASSUME_NONNULL_END
