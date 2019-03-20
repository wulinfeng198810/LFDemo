//
//  YYCache_TestVC.m
//  LFDemo
//
//  Created by wlf on 2019/2/15.
//  Copyright © 2019 lio. All rights reserved.
//

#import "YYCache_TestVC.h"
#import "DYCircleCacheHelper.h"
#import <YYKit.h>

@interface YYCache_TestVC ()

@end

@implementation YYCache_TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

//    [NSTimer timerWithTimeInterval:2 repeats:10 block:^(NSTimer * _Nonnull timer) {
//        YYCache *yyCache = [YYCache cacheWithName:kCacheStatisticsAppClass];
//        NSMutableArray *mArr = [[yyCache valueForKey:kCacheStatisticsAppClassID] mutableCopy];
//        NSLog(@"=========");
//        for (NSString *ID in mArr) {
//            NSLog(@"%@", ID);
//        }
//        NSLog(@"=========");
//    }];
}

- (void)testAction {
    [DYCircleCacheHelper cacheStatisticsAppClassID:@"1"];
    
//    //需要缓存的对象
//    NSString *userName = @[@"", @"1"];
//
//    //需要缓存的对象在缓存里对应的键
//    NSString *key = @"user_name";
//
//    //创建一个YYCache实例:userInfoCache
//    YYCache *userInfoCache = [YYCache cacheWithName:@"userInfo"];
//
//    //存入键值对
//    [userInfoCache setObject:userName forKey:key withBlock:^{
//        NSLog(@"caching object succeed");
//    }];
//
//    //判断缓存是否存在
//    [userInfoCache containsObjectForKey:key withBlock:^(NSString * _Nonnull key, BOOL contains) {
//        if (contains){
//            NSLog(@"object exists");
//        }
//    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
