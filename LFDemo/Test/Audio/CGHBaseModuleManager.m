//
//  CGHBaseModuleManager.m
//  MiniProgramExample
//
//  Created by wulinfeng on 2020/3/23.
//  Copyright © 2020 wulinfeng. All rights reserved.
//

#import "CGHBaseModuleManager.h"

@interface CGHBaseModuleManager()
@property (nonatomic, weak) id<CGHManagerProtocol> delegate;
@end

@implementation CGHBaseModuleManager
- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
@end
