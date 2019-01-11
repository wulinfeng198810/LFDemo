//
//  LFTextShowAllVC.m
//  LFDemo
//
//  Created by wlf on 2018/12/22.
//  Copyright © 2018 lio. All rights reserved.
//

#import "LFTextShowAllVC.h"
#import <YYKit.h>

@interface LFTextShowAllVC ()
@property (nonatomic, strong) UILabel *myLabel;
@end

@implementation LFTextShowAllVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = @"“瘦长鬼影”由Something Awful论坛用户Eric Knudson(又名Victor Surge，他也联合编写剧本) 在2009年创作，是一个身材高大瘦削、穿着黑西装、没有面部表情的男人，通常他会跟踪、绑架、伤害他人，尤其是孩童。随着时间推进，这一形象对流行文化产生了影响。2014年，一位12岁的女孩尝试刺杀一位同学，据称是受“瘦长鬼影”的影响。这一案件及背后的文化基因也被收录进了2016年的纪录片《小心瘦长鬼影》里。";
    NSAttributedString *introduceShowingAll;
    NSAttributedString *introducePacking;
    CGFloat introduceShowingAllHeight = 0;
    CGFloat introducePackingHeight = 0;
    
    CGFloat fontSize = 14;
    CGFloat wordWidth = fontSize+1;
    NSInteger sub3LineIndex = (kScreenWidth-30)/wordWidth*3;
    NSDictionary *normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName:UIColorHex(0x222222)};
    introduceShowingAll = [[NSAttributedString alloc] initWithString:text attributes:normalAttributes];
    CGSize size = [text sizeForFont:[UIFont systemFontOfSize:fontSize] size:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    introduceShowingAllHeight = size.height+2;
    
    if (size.height > fontSize*4) {//超过3行
        NSMutableAttributedString *attri;
        BOOL isShowAllIndictor = NO;
        if (isShowAllIndictor) {//最后加未展开的图标，表示未展开
            text = [[text substringToIndex:sub3LineIndex] stringByAppendingString:@"... "]; //50个字，大概三行；截断加省略号
            attri = [[NSMutableAttributedString alloc] initWithString:text attributes:normalAttributes];
            // 待展开图标
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            attch.image = [UIImage imageNamed:@"DYGameCenter.bundle/function/movie/tv_detail_downArrow"];
            attch.bounds = CGRectMake(0, 3, 9, 5);
            
            // 创建带有图片的富文本
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [attri appendAttributedString:string];
            
        } else {//最后加“展开”高亮，表示未展开
            text = [[text substringToIndex:sub3LineIndex] stringByAppendingString:@"..."]; //50个字，大概三行；截断加省略号
            attri = [[NSMutableAttributedString alloc] initWithString:text attributes:normalAttributes];
            NSDictionary *highlightAttributes = @{NSForegroundColorAttributeName:UIColorHex(0x586c96)};
            NSMutableAttributedString *showAllString = [[NSMutableAttributedString alloc] initWithString:@"展开" attributes:highlightAttributes];
            [attri appendAttributedString:showAllString];
        }
        introducePacking = attri;
        
        //未展开高度
        CGSize size = [introducePacking.string sizeForFont:[UIFont systemFontOfSize:fontSize] size:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
        introducePackingHeight = size.height+1;
    }
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, kScreenWidth-30, introduceShowingAllHeight)];
    myLabel.backgroundColor = UIColor.redColor;
    myLabel.numberOfLines = 0;
    myLabel.font = [UIFont systemFontOfSize:fontSize];
    myLabel.textAlignment = NSTextAlignmentLeft;
    myLabel.attributedText = introduceShowingAll;
    //    myLabel.text = text;
    [self.view addSubview:myLabel];
}

@end
