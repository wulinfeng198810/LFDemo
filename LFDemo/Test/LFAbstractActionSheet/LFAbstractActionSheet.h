//
//  LFAbstractActionSheet.h
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFAbstractActionSheetProtocol <NSObject>
- (UIView *)configuredContentView;
- (void)didDone;
- (void)didCancel;
@end

@interface LFAbstractActionSheet : UIView <LFAbstractActionSheetProtocol>
@property (nonatomic, assign) BOOL isAddCorner;
@property(nonatomic) NSMutableDictionary *pickerTextAttributes;
@property (readonly) UIButton *cancelBtn;
@property (readonly) UIButton *doneBtn;
@property (readonly) UIView *contentView;

- (void)showInContainer:(UIView *)inContainer;

- (void)dismiss:(BOOL)animated;

@end
