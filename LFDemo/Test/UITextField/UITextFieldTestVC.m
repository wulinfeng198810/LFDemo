//
//  UITextFieldTestVC.m
//  LFDemo
//
//  Created by wlf on 2019/1/11.
//  Copyright © 2019 lio. All rights reserved.
//

#import "UITextFieldTestVC.h"

@interface UITextFieldTestVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation UITextFieldTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSMutableString *mTextFieldString = (textField.text ?: @"").mutableCopy;
    if (range.length == 0 && string.length > 0) { //插入字符串
        [mTextFieldString insertString:string atIndex:range.location];
    } else if (range.length > 0 && string.length == 0) { //删除字符串
        [mTextFieldString replaceCharactersInRange:range withString:@""];
    } else {
        NSAssert(NO, @"输入异常");
        return NO;
    }
    
    //匹配以0开头的数字
    NSPredicate * predicate0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0][0-9]+$"];
    //匹配两位小数、整数
    NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(([1-9]{1}[0-9]*|[0])\\.?[0-9]{0,2})$"];
    if (!(![predicate0 evaluateWithObject:mTextFieldString] && [predicate1 evaluateWithObject:mTextFieldString])) {
        return NO;
    }
    
    //最大值限制
    CGFloat textValue = ceilf(mTextFieldString.floatValue);
    if (textValue > 100) {
        return NO;
    }
    
    return YES;
}


- (void)textFieldTextDidChange:(UITextField *)textField {
    NSLog(@"___%@___", textField.text);
}


@end

