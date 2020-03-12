//
//  FileDownloadCell.h
//  LFDemo
//
//  Created by wulinfeng on 2020/3/6.
//  Copyright © 2020 lio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadCell : UITableViewCell
@property (copy, nonatomic) void(^btnClickedBlock)(FileDownloadCell *cell);
- (void)refreshProgressLabel:(NSString *)text;
- (void)refreshResumeBtn:(NSString *)text;
- (void)refreshFileName:(NSString *)text;
- (void)refreshProgressText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
