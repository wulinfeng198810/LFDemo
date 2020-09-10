//
//  CGHInputView.m
//  LFDemo
//
//  Created by wulinfeng on 2020/4/23.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHInputView.h"
#import "YYKit.h"
#import "Masonry.h"

@interface CGHInputView() <UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *doneBtn;
@end

@implementation CGHInputView

- (instancetype)initWithFrame:(CGRect)frame showDoneBtn:(BOOL)showDoneBtn confirmButtonTitle:(NSString *)confirmButtonTitle {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorHex(0xe0e0e0);
        [self addSubview:self.textView];
        if (showDoneBtn) [self addSubview:self.doneBtn];
        [_doneBtn setTitle:confirmButtonTitle forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    if (_doneBtn) {
        [_doneBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.width.mas_equalTo(80);
        }];
        
        [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.right.equalTo(_doneBtn.mas_left).offset(-1);
        }];
        
    } else {
        [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self).offset(5);
            make.right.bottom.equalTo(self).offset(-5);
        }];
    }
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = UITextView.new;
        _textView.backgroundColor = UIColor.whiteColor;
        _textView.delegate = self;
        _textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _textView.tintColor = UIColorHex(0x009900);
        _textView.textColor = UIColor.blackColor;
        _textView.textAlignment = NSTextAlignmentNatural;
    }
    return _textView;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickedDone) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn = btn;
    }
    return _doneBtn;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textView.text.length) {
        return NO;
    }
    
    if (self.multiple == NO && [text isEqualToString:@"\n"]) {
        [self clickedDone];
        return NO;
    }

    NSMutableString *mTextFieldString = (textView.text ?: @"").mutableCopy;
    if (range.length == 0 && text.length > 0) { //插入字符串
        [mTextFieldString insertString:text atIndex:range.location];
    } else if (range.length > 0 && text.length == 0) { //删除字符串
        [mTextFieldString replaceCharactersInRange:range withString:@""];
        if (mTextFieldString.length == 0) { return YES; }
    } else {//智能提示，替换
        [mTextFieldString replaceCharactersInRange:range withString:text];
    }

    //长度限制
    if (mTextFieldString.length > self.maxLength) {
        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.textViewDidChange) self.textViewDidChange(self, self->_textView.text);
}

- (void)clickedDone {
    NSLog(@"~~~~done");
    if (self.didClickedConfirmBlock) self.didClickedConfirmBlock(self, self->_textView.text);
}

@end
