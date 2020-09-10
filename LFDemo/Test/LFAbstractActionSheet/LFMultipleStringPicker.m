//
//  LFMultipleStringPicker.m
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFMultipleStringPicker.h"

@interface LFMultipleStringPicker()
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *initialSelection;
@property (nonatomic, copy) LFMultipleStringPickerSelectBlock onSelect;
@property (nonatomic, copy) LFMultipleStringPickerDoneBlock onDone;
@property (nonatomic, copy) LFMultipleStringPickerCancelBlock onCancel;
@end

@implementation LFMultipleStringPicker

+ (instancetype)showInContainer:(UIView *)container rows:(NSArray<NSArray<NSString *> *> *)strings initialSelection:(NSArray *)indexes selectBlock:(LFMultipleStringPickerSelectBlock)selectBlock doneBlock:(LFMultipleStringPickerDoneBlock)doneBlock cancelBlock:(LFMultipleStringPickerCancelBlock)cancelBlock {
    LFMultipleStringPicker *picker = [[LFMultipleStringPicker alloc] init];
    picker.data = strings;
    picker.initialSelection = indexes;
    picker.onSelect = selectBlock;
    picker.onDone = doneBlock;
    picker.onCancel = cancelBlock;
    [picker showInContainer:container];
    return picker;
}

- (void)updateColumn:(NSUInteger)column columnData:(NSArray<NSString *> *)columnData selectedRow:(NSUInteger)selectedRow {
    NSMutableArray *array = self.data.mutableCopy;
    array[column] = columnData;
    [self setValue:array forKey:@"data"];
    
    UIPickerView *pickerView = (UIPickerView *)self.contentView;
    [pickerView reloadAllComponents];
    [pickerView selectRow:selectedRow inComponent:column animated:NO];
}

- (UIView *)configuredContentView {
    if (!self.data) return nil;
    CGRect pickerFrame = CGRectMake(0, 0, self.frame.size.width, 216);
    UIPickerView *stringPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    stringPicker.delegate = self;
    stringPicker.dataSource = self;

    [self performInitialSelectionInPickerView:stringPicker];

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
        self.onDone(self, [self selectedIndexes], [self selection]);
    }
}

- (void)didCancel {
    if (self.onCancel) {
        self.onCancel(self);
    }
}

#pragma mark - UIPickerViewDelegate / DataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.onSelect) {
        self.onSelect(self, row, component);
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.data count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return ((NSArray *)self.data[component]).count;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    id obj = (self.data)[component][row];
    pickerLabel.text = obj;
    return pickerLabel;
}

- (void)performInitialSelectionInPickerView:(UIPickerView *)pickerView {
    for (int i = 0; i < self.selectedIndexes.count; i++) {
        NSInteger row = [(NSNumber *)self.initialSelection[i] integerValue];
        [pickerView selectRow:row inComponent:i animated:NO];
    }
}

- (NSArray *)selection {
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0; i < self.data.count; i++) {
        id object = self.data[i][[(UIPickerView *)self.contentView selectedRowInComponent:(NSInteger)i]];
        [array addObject: object];
    }
    return [array copy];
}

- (NSArray *)selectedIndexes {
    NSMutableArray * indexes = [NSMutableArray array];
    for (int i = 0; i < self.data.count; i++) {
        NSNumber *index = [NSNumber numberWithInteger:[(UIPickerView *)self.contentView selectedRowInComponent:(NSInteger)i]];
        [indexes addObject: index];
    }
    return [indexes copy];
}

@end
