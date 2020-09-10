//
//  CGHInputView.h
//  LFDemo
//
//  Created by wulinfeng on 2020/4/23.
//  Copyright © 2020 lio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface CGHInputView : UIView
@property (readonly) UITextView *textView;
@property (nonatomic, assign) BOOL hideKeyboardWhenClickReturn;
@property (nonatomic, assign) BOOL multiple; //多行输入
@property (nonatomic, assign) NSUInteger maxLength; //键盘中文本的最大长度
@property (nonatomic, copy) void(^textViewDidChange)(CGHInputView *view, NSString *text);
@property (nonatomic, copy) void(^didClickedConfirmBlock)(CGHInputView *view, NSString *text);
- (instancetype)initWithFrame:(CGRect)frame showDoneBtn:(BOOL)showDoneBtn confirmButtonTitle:(NSString *)confirmButtonTitle;
@end

NS_ASSUME_NONNULL_END
