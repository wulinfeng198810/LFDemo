//
//  LFDatePicker.m
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFDatePicker.h"

@interface LFDatePicker()
@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, retain) NSDate *minimumDate;
@property (nonatomic, retain) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, assign) NSTimeInterval countDownDuration;
@property (nonatomic, copy) LFDatePickerDoneBlock onDone;
@property (nonatomic, copy) LFDatePickerCancelBlock onCancel;
@end

@implementation LFDatePicker

+ (instancetype)showInContainer:(UIView *)container datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate doneBlock:(LFDatePickerDoneBlock)doneBlock cancelBlock:(LFDatePickerCancelBlock)cancelBlock {
    LFDatePicker *picker = [[LFDatePicker alloc] init];
    picker.datePickerMode = datePickerMode;
    picker.selectedDate = selectedDate;
    picker.minimumDate = minimumDate;
    picker.maximumDate = maximumDate;
    picker.onDone = doneBlock;
    picker.onCancel = cancelBlock;
    [picker showInContainer:container];
    return picker;
}

- (UIView *)configuredContentView {
    CGRect datePickerFrame = CGRectMake(0, 40, self.frame.size.width, 216);
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:datePickerFrame];
    datePicker.datePickerMode = self.datePickerMode;
    datePicker.maximumDate = self.maximumDate;
    datePicker.minimumDate = self.minimumDate;

    // if datepicker is set with a date in countDownMode then
    // 1h is added to the initial countdown
    if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
        datePicker.countDownDuration = self.countDownDuration;
        // Due to a bug in UIDatePicker, countDownDuration needs to be set asynchronously
        // more info: http://stackoverflow.com/a/20204317/1161723
        dispatch_async(dispatch_get_main_queue(), ^{
            datePicker.countDownDuration = self.countDownDuration;
        });
    } else {
        [datePicker setDate:self.selectedDate animated:NO];
    }

    [datePicker addTarget:self action:@selector(eventForDatePicker:) forControlEvents:UIControlEventValueChanged];
    
    return datePicker;
}

- (void)didDone {
    if (self.onDone) {
        if (self.datePickerMode == UIDatePickerModeCountDownTimer)
            self.onDone(self, @(((UIDatePicker *)self.contentView).countDownDuration));
        else
            self.onDone(self, self.selectedDate);
    }
}

- (void)didCancel {
    if (self.onCancel) {
        self.onCancel(self);
    }
}

- (void)eventForDatePicker:(id)sender
{
    if (!sender || ![sender isKindOfClass:[UIDatePicker class]])
        return;
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.selectedDate = datePicker.date;
    self.countDownDuration = datePicker.countDownDuration;
}

@end
