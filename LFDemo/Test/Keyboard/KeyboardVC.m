//
//  KeyboardVC.m
//  LFDemo
//
//  Created by wulinfeng on 2020/4/23.
//  Copyright © 2020 lio. All rights reserved.
//

#import "KeyboardVC.h"
#import "CGHKeyboardManager.h"

@interface KeyboardVC ()
@property (nonatomic, strong) CGHKeyboardManager *keyboardManager;
@end

@implementation KeyboardVC
{
    BOOL _showKeyboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.keyboardManager = CGHKeyboardManager.new;
}

- (IBAction)clickBtn:(id)sender {
    _showKeyboard = !_showKeyboard;
    if (_showKeyboard) {
        [self.keyboardManager showKeyboard:self.view args:@{}];
    } else {
        [self.keyboardManager hideKeyboard];
    }
}

@end
