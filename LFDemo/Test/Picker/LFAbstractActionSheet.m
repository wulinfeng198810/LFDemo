//
//  LFAbstractActionSheet.m
//  LFDemo
//
//  Created by wulinfeng on 2020/9/10.
//  Copyright © 2020 lio. All rights reserved.
//

#import "LFAbstractActionSheet.h"
#import "Masonry.h"
#import "YYKit.h"

#define kUIScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kUIScreenHeight ([UIScreen mainScreen].bounds.size.height)

//是否是X系列手机
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define IS_IPHONE_XSeries (IS_IOS_11 && IS_IPHONE && (MIN(kUIScreenWidth, kUIScreenHeight) >= 375 && MAX(kUIScreenWidth, kUIScreenHeight) >= 812))

//SafeBottomHeight
#define kSafeBottomHeight         (IS_IPHONE_XSeries ? 34.f : 0)

@interface LFAbstractActionSheet()
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) CGFloat toolbarHeight;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation LFAbstractActionSheet
- (CGFloat)contentViewHeight {
    return kSafeBottomHeight+self.toolbarHeight+self.contentHeight;
}

- (CGFloat)contentViewWidth {
    return self.frame.size.width;
}

#pragma mark - subviews
- (void)setupSubviews {
    [self addSubview:self.blurView];
    [self addSubview:self.contentBgView];
    [self.contentBgView addSubview:self.contentView];
    [self.contentBgView addSubview:self.toolbarView];
    [self.toolbarView addSubview:self.cancelBtn];
    [self.toolbarView addSubview:self.doneBtn];
    
    //layout
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y+self.toolbarHeight, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.width.mas_equalTo([self contentViewWidth]);
        make.height.mas_equalTo([self contentViewHeight]);
    }];
    
    UIView *toolbarBottomSepLine = [[UIView alloc] init];
    toolbarBottomSepLine.backgroundColor = UIColorHex(0xe0e0e0);
    [self.toolbarView addSubview:toolbarBottomSepLine];
    [toolbarBottomSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(self.toolbarHeight);
    }];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(0);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(self.toolbarHeight);
    }];
    
    [self layoutIfNeeded];
    if (self.isAddCorner) [self contentViewAddCorner];
}

- (void)contentViewAddCorner {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentBgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentBgView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentBgView.layer.mask = maskLayer;
}

#pragma mark - show / dismiss
- (void)show:(UIView *)content inContainer:(UIView *)inContainer {
    [inContainer addSubview:self];
    self.frame = CGRectMake(0, 0, inContainer.frame.size.width, inContainer.frame.size.height);
    self.contentView = content;
    self.toolbarHeight = 40;
    self.contentHeight = CGRectGetMaxY(content.frame);
    [self setupSubviews];
    [self _showOrDismiss:YES];
}

- (void)dismiss:(BOOL)animated {
    if (!animated) {
        [self removeFromSuperview];
        return;
    }
    
    [self _showOrDismiss:NO];
}

- (void)_showOrDismiss:(BOOL)isShow {
    //动画前
    isShow ? [self __dissmiss] : [self __show];
    [self layoutIfNeeded];
    
    //动画后
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.25 animations: ^{
        isShow ? [self __show] : [self __dissmiss];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!isShow) {
            [self removeFromSuperview];
        }
    }];
}

- (void)__show {
    self.blurView.alpha = 0.2;
    
    [self.contentBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
    }];
}

- (void)__dissmiss {
    self.blurView.alpha = 0;
    
    [self.contentBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset([self contentViewHeight]);
    }];
}

#pragma mark - lazy
- (UIView *)blurView {
    if (!_blurView) {
        _blurView = [UIView new];
        _blurView.backgroundColor = [UIColor blackColor];
        _blurView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlurAction)];
        [_blurView addGestureRecognizer:tap];
    }
    return _blurView;
}

- (UIView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [UIView new];
        _contentBgView.backgroundColor = UIColor.whiteColor;
        
        /*
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        effectView.frame = CGRectMake(0, 0, [self contentViewWidth], [self contentViewHeight]);
        [_contentView addSubview:effectView];
         */
    }
    return _contentBgView;
}

- (UIView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self contentViewWidth], self.toolbarHeight)];
        _toolbarView.backgroundColor = UIColor.clearColor;
    }
    return _toolbarView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _cancelBtn.backgroundColor = UIColor.clearColor;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:UIColorHex(0x666666) forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _doneBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _doneBtn.backgroundColor = UIColor.clearColor;
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

#pragma mark - actions
- (void)tapBlurAction {
    [self dismiss:YES];
}

- (void)clickCancelBtn {
    [self dismiss:YES];
}

- (void)clickDoneBtn {
    [self dismiss:NO];
}

@end

