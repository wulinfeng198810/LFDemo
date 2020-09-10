//
//  LFAbstractActionSheet.h
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFAbstractActionSheet : UIView
@property (nonatomic, assign) BOOL isAddCorner;
@property (readonly) UIButton *cancelBtn;
@property (readonly) UIButton *doneBtn;
@property (readonly) UIView *contentView;

- (void)show:(UIView *)content inContainer:(UIView *)inContainer;

- (void)dismiss:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
