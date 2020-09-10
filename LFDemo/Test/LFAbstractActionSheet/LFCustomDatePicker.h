//
//  LFCustomDatePicker.h
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFAbstractActionSheet.h"

@class LFCustomDatePicker;
typedef void(^LFCustomDatePickerDoneBlock)(LFCustomDatePicker *picker, id selectedDate);
typedef void(^LFCustomDatePickerCancelBlock)(LFCustomDatePicker *picker);

/// 日期选择器格式
typedef NS_ENUM(NSInteger, CGHDatePickerMode) {
    CGHDatePickerModeYear,
    CGHDatePickerModeYearMonth
};

@interface LFCustomDatePicker : LFAbstractActionSheet
+ (instancetype)showInContainer:(UIView *)container
                 datePickerMode:(CGHDatePickerMode)datePickerMode
                   selectedDate:(NSDate *)selectedDate
                    minimumDate:(NSDate *)minimumDate
                    maximumDate:(NSDate *)maximumDate
                      doneBlock:(LFCustomDatePickerDoneBlock)doneBlock
                    cancelBlock:(LFCustomDatePickerCancelBlock)cancelBlock;
@end
