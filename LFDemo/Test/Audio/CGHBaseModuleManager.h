//
//  CGHBaseModuleManager.h
//  MiniProgramExample
//
//  Created by wulinfeng on 2020/3/23.
//  Copyright © 2020 wulinfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CGHAppServiceOnEventDispatcherProtocol <NSObject>
/**
 APPSERVICE_ON_EVENT
 */
- (void)APPSERVICE_ON_EVENT:(NSString *)eventName data:(NSDictionary *)data;
@end

@protocol CGHManagerProtocol <NSObject>
@property (readonly) id<CGHAppServiceOnEventDispatcherProtocol> appServiceOnEventDispatcher;
@property (readonly) id appInfo;
@end

NS_ASSUME_NONNULL_BEGIN

@interface CGHBaseModuleManager : NSObject
@property (nonatomic, weak, readonly) id<CGHManagerProtocol> delegate;
- (instancetype)initWithDelegate:(id)delegate;
@end

NS_ASSUME_NONNULL_END
