//
//  ErrorImageTestVC.m
//  LFDemo
//
//  Created by wlf on 2019/1/16.
//  Copyright © 2019 lio. All rights reserved.
//

#import "ErrorImageTestVC.h"
#import <UIImageView+WebCache.h>
#import <YYKit.h>

@interface ErrorImageTestVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ErrorImageTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://dyt1.oss-cn-shenzhen.aliyuncs.com/dianyou/data/circle/img/20181209/c4355ba4bb0323410e34022301e46bab.png"];
//    [self.imageView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        NSLog(@"");
//    }];
    @weakify(self);
    [[YYWebImageManager sharedManager] requestImageWithURL:url options:YYWebImageOptionAvoidSetImage progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        @strongify(self);
        if (image && stage == YYWebImageStageFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        } else {
            NSLog(@"%d", stage);
        }
    }];
    
//    @weakify(self);
//    [self.imageView.layer setImageWithURL:url placeholder:nil options:YYWebImageOptionAvoidSetImage completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//        @strongify(self);
//        if (image && stage == YYWebImageStageFinished) {
//            self.imageView.image = image;
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
