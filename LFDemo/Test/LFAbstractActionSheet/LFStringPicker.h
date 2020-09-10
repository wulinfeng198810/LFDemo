//
//  LFStringPicker.h
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFAbstractActionSheet.h"

@class LFStringPicker;
typedef void(^LFStringPickerDoneBlock)(LFStringPicker *picker, NSInteger selectedIndex, id selectedValue);
typedef void(^LFStringPickerCancelBlock)(LFStringPicker *picker);

@interface LFStringPicker : LFAbstractActionSheet <UIPickerViewDelegate, UIPickerViewDataSource>

+ (instancetype)showInContainer:(UIView *)container
                           rows:(NSArray<NSString*> *)strings
               initialSelection:(NSInteger)index
                      doneBlock:(LFStringPickerDoneBlock)doneBlock
                    cancelBlock:(LFStringPickerCancelBlock)cancelBlock;

@end
