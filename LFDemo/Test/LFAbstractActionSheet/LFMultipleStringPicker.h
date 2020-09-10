//
//  LFMultipleStringPicker.h
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFAbstractActionSheet.h"

@class LFMultipleStringPicker;
typedef void(^LFMultipleStringPickerSelectBlock)(LFMultipleStringPicker *picker, NSInteger row, NSInteger inComponent);
typedef void(^LFMultipleStringPickerDoneBlock)(LFMultipleStringPicker *picker, NSArray *selectedIndexes, id selectedValues);
typedef void(^LFMultipleStringPickerCancelBlock)(LFMultipleStringPicker *picker);

@interface LFMultipleStringPicker : LFAbstractActionSheet <UIPickerViewDelegate, UIPickerViewDataSource>

+ (instancetype)showInContainer:(UIView *)container
                           rows:(NSArray<NSArray<NSString*>*> *)strings
               initialSelection:(NSArray *)indexes
                    selectBlock:(LFMultipleStringPickerSelectBlock)selectBlock
                      doneBlock:(LFMultipleStringPickerDoneBlock)doneBlock
                    cancelBlock:(LFMultipleStringPickerCancelBlock)cancelBlock;

- (void)updateColumn:(NSUInteger)column columnData:(NSArray<NSString *> *)columnData selectedRow:(NSUInteger)selectedRow;

@end
