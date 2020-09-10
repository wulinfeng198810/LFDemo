//
//  LFDatePicker.h
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFAbstractActionSheet.h"

@class LFDatePicker;
typedef void(^LFDatePickerDoneBlock)(LFDatePicker *picker, id selectedDate);
typedef void(^LFDatePickerCancelBlock)(LFDatePicker *picker);

@interface LFDatePicker : LFAbstractActionSheet
+ (instancetype)showInContainer:(UIView *)container
                 datePickerMode:(UIDatePickerMode)datePickerMode
                   selectedDate:(NSDate *)selectedDate
                    minimumDate:(NSDate *)minimumDate
                    maximumDate:(NSDate *)maximumDate
                      doneBlock:(LFDatePickerDoneBlock)doneBlock
                    cancelBlock:(LFDatePickerCancelBlock)cancelBlock;
@end
