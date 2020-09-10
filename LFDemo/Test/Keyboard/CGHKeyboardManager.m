//
//  CGHKeyboardManager.m
//  LFDemo
//
//  Created by wulinfeng on 2020/4/23.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHKeyboardManager.h"
#import "CGHInputView.h"
#import "YYKit.h"
#import "Masonry.h"

@interface CGHKeyboardManager()
@property (nonatomic, strong) CGHInputView *inputView;
@end

@implementation CGHKeyboardManager
{
    UIView *_onView;
    NSDictionary *_args;
}

- (void)showKeyboard:(UIView *)onView args:(nonnull NSDictionary *)args {
    if (!onView) return;
    _onView = onView;
    _args = args;
    
    args =
  @{@"defaultValue":@"123123",
    @"multiple":    @(NO),
    @"confirmHold": @(NO),
    @"confirmHold": @(NO),
    @"confirmType": @"search",
  };
    
    BOOL multiple = [args[@"multiple"] boolValue];
    NSUInteger maxLength = [args[@"maxLength"] unsignedIntValue] ?: 50;
    
    [self removeObserver];
    [self addObserver];
    CGFloat inputViewHeight = multiple ? 80 : 40;
    self.inputView = [[CGHInputView alloc] initWithFrame:CGRectMake(0, onView.bounds.size.height-inputViewHeight, onView.bounds.size.width, inputViewHeight) showDoneBtn:multiple confirmButtonTitle:[self returnKeyDesc:args[@"confirmType"]]];
    [onView addSubview:self.inputView];
    
    //args
    self.inputView.textView.text = args[@"defaultValue"] ?: @"";
    self.inputView.maxLength = maxLength;
    self.inputView.hideKeyboardWhenClickReturn = NO == [args[@"confirmHold"] boolValue];
    self.inputView.textView.returnKeyType = multiple ? UIReturnKeyDefault : [self returnKeyType:args[@"confirmType"]];
    
//    @weakify(self);
    self.inputView.didClickedConfirmBlock = ^(CGHInputView * _Nonnull view, NSString * _Nonnull text) {
//        @strongify(self);
        if (view.hideKeyboardWhenClickReturn) {
            [view.textView resignFirstResponder];
        }
    };
    
    //弹键盘
    if ([self.inputView.textView canBecomeFirstResponder]) {
        [self.inputView.textView becomeFirstResponder];
    }
}

- (void)hideKeyboard {
    if ([self.inputView.textView isFirstResponder]) {
        [self.inputView.textView resignFirstResponder];
    }
    [self.inputView removeFromSuperview];
    self.inputView = nil;
}

#pragma mark - private
- (UIReturnKeyType)returnKeyType:(NSString *)type {
    if (!type) return UIReturnKeyDone;
    NSDictionary *dict =
  @{@"done": @(UIReturnKeyDone),
    @"next": @(UIReturnKeyNext),
    @"search": @(UIReturnKeySearch),
    @"go": @(UIReturnKeyGo),
    @"send": @(UIReturnKeySend)};
    id obj = dict[type];
    if (!obj) return UIReturnKeyDone;
    return (UIReturnKeyType)[obj integerValue];
}

- (NSString *)returnKeyDesc:(NSString *)type {
    if (!type) return @"完成";
    NSDictionary *dict =
  @{@"done": @"完成",
    @"next": @"下一个",
    @"search": @"搜索",
    @"go": @"前往",
    @"send": @"发送"};
    NSString *obj = dict[type];
    return obj ? obj : @"完成";
}

#pragma mark - keyboard
- (void)addObserver {
    // 监听弹起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 监听隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // 监听frame
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    NSDictionary *keyboardAnimationDetail = [notification userInfo];
    UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGRect keyboardFrameRect = [(NSValue*)[keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    //working for hardware keyboard
    //UIViewAnimationOptions options = (UIViewAnimationOptions)animationCurve;

    //working for virtual keyboard
    UIViewAnimationOptions options = (animationCurve <<16);

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.inputView.frame = CGRectMake(0, self->_onView.bounds.size.height - (keyboardFrameRect.size.height+self.inputView.bounds.size.height), self.inputView.bounds.size.width, self.inputView.bounds.size.height);
    } completion:nil];
}

- (void)keyBoardDidShow:(NSNotification *)notification {
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self hideKeyboard];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification{
}

@end
