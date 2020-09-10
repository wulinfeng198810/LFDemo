//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreServices/UTCoreTypes.h>
#import <YYKit.h>
#import "LFStringPicker.h"
#import "LFMultipleStringPicker.h"
#import "LFDatePicker.h"
#import "LFCustomDatePicker.h"

#define DY_APPSTORE 1

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UILabel *badgeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (IBAction)testAction:(id)sender {
//    UIViewController *vc = [[TestAudioVC alloc] initWithNibName:@"TestAudioVC" bundle:NSBundle.mainBundle];
////    [self.navigationController pushViewController:NSClassFromString(@"JSContextTestVC").new animated:YES];
//    [self.navigationController pushViewController:vc animated:YES];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    [LFStringPicker showInContainer:self.view rows:@[@"1", @"2", @"3"] initialSelection:1 doneBlock:^(LFStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//        NSLog(@"LFStringPicker:%@", selectedValue);
//    } cancelBlock:^(LFStringPicker *picker) {
//        NSLog(@"cancel:%@", picker);
//    }];
//
    [LFMultipleStringPicker showInContainer:self.view rows:@[@[@"1", @"2", @"3"], @[@"11", @"22", @"33"], @[@"111", @"222", @"333"], @[@"1111", @"2222", @"3333"]] initialSelection:@[@1, @2, @2, @2] selectBlock:^(LFMultipleStringPicker *picker, NSInteger row, NSInteger inComponent) {
        if (inComponent == 1) {
            [picker updateColumn:2 columnData:@[@"aaa", @"bbb", @"ccc"] selectedRow:2];
        }
    } doneBlock:^(LFMultipleStringPicker *picker, NSArray *selectedIndexes, id selectedValues) {
        NSLog(@"%@", selectedIndexes);
    } cancelBlock:^(LFMultipleStringPicker *picker) {
        NSLog(@"cancel:%@", picker);
    }];
//
//    NSDateFormatter*formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"MM-dd";
//    NSDate *min = [formatter dateFromString:@"09-02"];
//    NSDate *max = [formatter dateFromString:@"09-10"];
//    NSDate *sel = [formatter dateFromString:@"09-05"];
//    [LFDatePicker showInContainer:self.view datePickerMode:UIDatePickerModeDate selectedDate:sel minimumDate:min maximumDate:max doneBlock:^(LFDatePicker *picker, NSDate *selectedDate) {
//        NSLog(@"%@", [formatter stringFromDate:selectedDate]);
//    } cancelBlock:^(LFDatePicker *picker) {
//        NSLog(@"cancel:%@", picker);
//    }];
    
//    NSDateFormatter*formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy-MM";
//    NSDate *min = [formatter dateFromString:@"2010-02"];
//    NSDate *max = [formatter dateFromString:@"2020-10"];
//    NSDate *sel = [formatter dateFromString:@"2011-05"];
//    [LFCustomDatePicker showInContainer:self.view datePickerMode:CGHDatePickerModeYearMonth selectedDate:sel minimumDate:min maximumDate:max doneBlock:^(LFCustomDatePicker *picker, id selectedDate) {
//        NSLog(@"%@", [formatter stringFromDate:selectedDate]);
//    } cancelBlock:^(LFCustomDatePicker *picker) {
//        NSLog(@"cancel:%@", picker);
//    }];
}

@end
