//
//  LFStringPicker.m
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFStringPicker.h"

@interface LFStringPicker()
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) LFStringPickerDoneBlock onDone;
@property (nonatomic, copy) LFStringPickerCancelBlock onCancel;
@end

@implementation LFStringPicker

+ (instancetype)showInContainer:(UIView *)container rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(LFStringPickerDoneBlock)doneBlock cancelBlock:(LFStringPickerCancelBlock)cancelBlock {
    LFStringPicker *picker = [[LFStringPicker alloc] init];
    picker.data = strings;
    picker.selectedIndex = index;
    picker.onDone = doneBlock;
    picker.onCancel = cancelBlock;
    [picker showInContainer:container];
    return picker;
}

- (UIView *)configuredContentView {
    if (!self.data) return nil;
    CGRect pickerFrame = CGRectMake(0, 0, self.frame.size.width, 216);
    UIPickerView *stringPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    stringPicker.delegate = self;
    stringPicker.dataSource = self;
    [stringPicker selectRow:self.selectedIndex inComponent:0 animated:NO];
    if (self.data.count == 0) {
        stringPicker.showsSelectionIndicator = NO;
        stringPicker.userInteractionEnabled = NO;
    } else {
        stringPicker.showsSelectionIndicator = YES;
        stringPicker.userInteractionEnabled = YES;
    }
    return stringPicker;
}

- (void)didDone {
    if (self.onDone) {
        id selectedObject = (self.data.count > 0) ? self.data[self.selectedIndex] : nil;
        self.onDone(self, self.selectedIndex, selectedObject);
    }
}

- (void)didCancel {
    if (self.onCancel) {
        self.onCancel(self);
    }
}

#pragma mark - UIPickerViewDelegate / DataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndex = row;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id obj = self.data[row];
    if ([obj isKindOfClass:[NSString class]])
        return obj;

    if ([obj respondsToSelector:@selector(description)])
        return [obj performSelector:@selector(description)];
    
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    id obj = self.data[row];
    pickerLabel.text = obj;
    return pickerLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.frame.size.width - 30;
}

@end
