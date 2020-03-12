//
//  TestFileDownloadTableVC.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/6.
//  Copyright © 2020 lio. All rights reserved.
//

#import "TestFileDownloadTableVC.h"
#import "FileDownloadCell.h"
#import "CGHDownloadManager.h"
#import "YYKit.h"

@interface TestFileDownloadTableVC ()
@property (nonatomic, strong) NSArray *datas;
@end

@implementation TestFileDownloadTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas =
  @[@"http://alfs.chigua.cn/dianyou/data/platform/default/20200303/cg2f32b45b22e9fe15-3.0.4.zip",
//    @"http://alfs.chigua.cn/dianyou/data/platform/default/20200305/cgb0dfd1547e0b165b-3.0.0.26.zip",
    @"http://alfs.chigua.cn/dianyou/data/platform/default/20200306/cg16cf0c1c3f84c33b-3.0.0.11.zip",
//    @"http://alfs.chigua.cn/dianyou/data/platform/default/20200114/cg3df54a19a2d94e62-2.8.1.zip",
    
    @"http://pic1.win4000.com/wallpaper/2018-09-17/5b9f708aaafca.jpg",
    @"http://a.hiphotos.baidu.com/zhidao/pic/item/2f738bd4b31c8701012eec802f7f9e2f0708ff38.jpg",];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FileDownloadCell" bundle:nil] forCellReuseIdentifier:@"FileDownloadCell"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileDownloadCell"];
    if (!cell) {
        cell =  [[NSBundle mainBundle]loadNibNamed:@"FileDownloadCell" owner:self options:nil].firstObject;
    }
    NSString *url = self.datas[indexPath.row];
    [cell refreshFileName:url.lastPathComponent];
    cell.btnClickedBlock = ^(FileDownloadCell * _Nonnull cell) {
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *destUrl = [document stringByAppendingPathComponent:url.lastPathComponent];
        
        @weakify(cell);
        [[CGHDownloadManager shareManager] download:url toPath:destUrl progress:^(int64_t totalUnitCount, int64_t completedUnitCount) {
            @strongify(cell);
            float _progress = completedUnitCount*100.0/(totalUnitCount > 0 ? totalUnitCount : 1);
            [cell refreshProgressLabel:[NSString stringWithFormat:@"%.2f%%", _progress]];
            [cell refreshProgressText:[NSString stringWithFormat:@"%@/%@", [self displayFileSize:completedUnitCount], [self displayFileSize:totalUnitCount]]];
        } completionHandler:^(NSURL *filePath, NSError *error) {
            ;
        }];
    };
    return cell;
}
  
/**
 * 文件字节大小显示成M,G和K
 */
- (NSString*)displayFileSize:(float)size {
    //字节大小，K,M,G
    static const long KB = 1024;
    static const long MB = KB * 1024;
    static const long GB = MB * 1024;
    
    if (size >= GB) {
        return [NSString stringWithFormat:@"%.1fGB", size / GB];
    } else if (size >= MB) {
        float value = (float) size / MB;
        return [NSString stringWithFormat:value > 100 ? @"%.0fMB" : @"%.1fMB", value];
    } else if (size >= KB) {
        float value = (float) size / KB;
        return [NSString stringWithFormat:value > 100 ? @"%.0fKB" : @"%.1fKB", value];
    } else {
        return [NSString stringWithFormat:@"%dB", (int)size];
    }
}

@end
