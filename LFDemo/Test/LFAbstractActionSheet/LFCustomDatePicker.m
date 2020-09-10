//
//  LFCustomDatePicker.m
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFCustomDatePicker.h"
#import "NSDate+YYAdd.h"

@interface LFCustomDatePicker() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, assign) CGHDatePickerMode datePickerMode;
@property (nonatomic, retain) NSDate *minimumDate;
@property (nonatomic, retain) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, copy) LFCustomDatePickerDoneBlock onDone;
@property (nonatomic, copy) LFCustomDatePickerCancelBlock onCancel;

@property (nonatomic, copy) NSArray<NSString*> *years;
@property (nonatomic, copy) NSArray<NSString*> *months;
@property(nonatomic, assign) NSInteger yearIndex;
@property(nonatomic, assign) NSInteger monthIndex;
@end

@implementation LFCustomDatePicker

+ (instancetype)showInContainer:(UIView *)container datePickerMode:(CGHDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate doneBlock:(LFCustomDatePickerDoneBlock)doneBlock cancelBlock:(LFCustomDatePickerCancelBlock)cancelBlock {
    LFCustomDatePicker *picker = [[LFCustomDatePicker alloc] init];
    picker.datePickerMode = datePickerMode;
    picker.currentDate = selectedDate;
    picker.minimumDate = minimumDate;
    picker.maximumDate = maximumDate;
    picker.onDone = doneBlock;
    picker.onCancel = cancelBlock;
    [picker showInContainer:container];
    return picker;
}

- (UIView *)configuredContentView {
    self.years = [self getYearArr:self.minimumDate maximumDate:self.maximumDate];
    NSUInteger yearIndex = [self.years indexOfObject:@(self.currentDate.year).stringValue];
    self.yearIndex = yearIndex == NSNotFound ? 0 : yearIndex;
    
    if (self.datePickerMode == CGHDatePickerModeYearMonth) {
        self.months = [self getMonthArr:self.currentDate.year minimumDate:self.minimumDate maximumDate:self.maximumDate];
        NSUInteger monthIndex = [self.months indexOfObject:@(self.currentDate.month).stringValue];
        self.monthIndex = monthIndex == NSNotFound ? 0 : monthIndex;
    }
    
    CGRect pickerFrame = CGRectMake(0, 0, self.frame.size.width, 216);
    UIPickerView *stringPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    stringPicker.delegate = self;
    stringPicker.dataSource = self;
    
    if(self.years.count > 0) [stringPicker selectRow:self.yearIndex inComponent:0 animated:NO];
    if(self.months.count > 0) [stringPicker selectRow:self.monthIndex inComponent:1 animated:NO];
    
    return stringPicker;
}

- (void)didDone {
    NSDate *selectedDate;
    if (self.datePickerMode == CGHDatePickerModeYear) {
        NSString *dateStr = self.years[self.yearIndex];
        selectedDate = [NSDate dateWithString:dateStr format:@"yyyy"];
    } else if (self.datePickerMode == CGHDatePickerModeYearMonth) {
        NSString *dateStr = [NSString stringWithFormat:@"%4ld-%2ld", (long)self.years[self.yearIndex].integerValue, (long)self.months[self.monthIndex].integerValue];
        selectedDate = [NSDate dateWithString:dateStr format:@"yyyy-MM"];
    }
    if (self.onDone) self.onDone(self, selectedDate);
}

- (void)didCancel {
    if (self.onCancel) {
        self.onCancel(self);
    }
}

#pragma mark - util
// 获取 yearArr 数组
- (NSArray *)getYearArr:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate {
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSInteger i = minimumDate.year; i <= maximumDate.year; i++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

// 获取 monthArr 数组
- (NSArray *)getMonthArr:(NSInteger)year minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate {
    NSInteger startMonth = 1;
    NSInteger endMonth = 12;
    if (year == minimumDate.year) {
        startMonth = minimumDate.month;
    }
    if (year == maximumDate.year) {
        endMonth = maximumDate.month;
    }
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:(endMonth - startMonth + 1)];
    for (NSInteger i = startMonth; i <= endMonth; i++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

#pragma mark - UIPickerViewDelegate / DataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.yearIndex = row;
    } else if (component == 1) {
        self.monthIndex = row;
    }
    
    if (self.datePickerMode == CGHDatePickerModeYearMonth) {
        if (component == 0) {
            NSUInteger year = [self.years[row] integerValue];
            self.months = [self getMonthArr:year minimumDate:self.minimumDate maximumDate:self.maximumDate];
            UIPickerView *pickerView = (UIPickerView *)self.contentView;
            [pickerView reloadComponent:1];
            self.monthIndex = 0;
            [pickerView selectRow:self.monthIndex inComponent:1 animated:NO];
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.datePickerMode == CGHDatePickerModeYear) {
        return 1;
    } else if (self.datePickerMode == CGHDatePickerModeYearMonth) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.years.count;
    } else if (component == 1) {
        return self.months.count;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    id obj;
    if (component == 0) {
        obj = [self.years[row] stringByAppendingString:@"年"];
    } else if (component == 1) {
        obj = [self.months[row] stringByAppendingString:@"月"];
    }
    pickerLabel.text = obj;
    return pickerLabel;
}

@end
