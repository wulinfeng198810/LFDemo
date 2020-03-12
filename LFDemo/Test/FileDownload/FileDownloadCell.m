//
//  FileDownloadCell.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/6.
//  Copyright © 2020 lio. All rights reserved.
//

#import "FileDownloadCell.h"

@interface FileDownloadCell()
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *progressText;
@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;
@end

@implementation FileDownloadCell

- (IBAction)didClickResumeBtn:(UIButton *)sender {
    !self.btnClickedBlock ?: self.btnClickedBlock(self);
}

#pragma mark - public
- (void)refreshProgressLabel:(NSString *)text {
    self.progressLabel.text = text;
}

- (void)refreshResumeBtn:(NSString *)text {
    [self.resumeBtn setTitle:text forState:UIControlStateNormal];
}

- (void)refreshFileName:(NSString *)text {
    self.fileName.text = text;
}

- (void)refreshProgressText:(NSString *)text {
    self.progressText.text = text;
}

@end
