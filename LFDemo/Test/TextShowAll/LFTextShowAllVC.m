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
    
    NSString *text = @"《奔腾岁月》是华策影视集团出品的跨年代励志剧，由王飞执导，于川、胡亚编剧，李宗翰领衔主演，张粟、瑛子、夏一瑶、周密等主演。该剧以中国改革开放、奇迹崛起的40年为创作背景，刻画了大时代下热血奋斗的小人物，谱写了一曲中国民营企业家的“人间正道是沧桑”。\">《奔腾岁月》是华策影视集团出品的跨年代励志剧，由王飞执导，于川、胡亚编剧，李宗翰领衔主演，张粟、瑛子、夏一瑶、周密等主演。该剧以中国改革开放、奇迹崛起的40年为创作背景，刻画了大时代下热血奋斗的小人物，谱写了一曲中国民营企业家的“人间正道是沧桑";
    NSAttributedString *introduceShowingAll;
    NSAttributedString *introducePacking;
    CGFloat introduceShowingAllHeight = 0;
    CGFloat introducePackingHeight = 0;
    
    CGFloat fontSize = 14;
    CGFloat wordWidth = fontSize+1;
    NSDictionary *normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName:UIColorHex(0x222222)};
    introduceShowingAll = [[NSAttributedString alloc] initWithString:text attributes:normalAttributes];
    CGSize size = [text sizeForFont:[UIFont systemFontOfSize:fontSize] size:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) mode:NSLineBreakByCharWrapping];
    introduceShowingAllHeight = size.height;
    
    if (size.height > fontSize*4) {//超过3行
        NSMutableAttributedString *attri;
        BOOL isShowAllIndictor = YES;
        if (isShowAllIndictor) {//最后加未展开的图标，表示未展开
            text = [[text substringToIndex:(kScreenWidth-30)/wordWidth*3] stringByAppendingString:@"... "]; //50个字，大概三行；截断加省略号
            attri = [[NSMutableAttributedString alloc] initWithString:text attributes:normalAttributes];
            // 待展开图标
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            attch.image = [UIImage imageNamed:@"DYGameCenter.bundle/function/movie/tv_detail_downArrow"];
            attch.bounds = CGRectMake(0, 3, 9, 5);
            
            // 创建带有图片的富文本
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            [attri appendAttributedString:string];
            
        } else {//最后加“展开”高亮，表示未展开
            text = [[text substringToIndex:50] stringByAppendingString:@"..."]; //50个字，大概三行；截断加省略号
            attri = [[NSMutableAttributedString alloc] initWithString:text attributes:normalAttributes];
            NSDictionary *highlightAttributes = @{NSForegroundColorAttributeName:UIColorHex(0x586c96)};
            NSMutableAttributedString *showAllString = [[NSMutableAttributedString alloc] initWithString:@"展开" attributes:highlightAttributes];
            [attri appendAttributedString:showAllString];
        }
        introducePacking = attri;
        
        //未展开高度
        CGSize size = [introducePacking.string sizeForFont:[UIFont systemFontOfSize:fontSize] size:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) mode:NSLineBreakByCharWrapping];
        introducePackingHeight = size.height;
    }
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, kScreenWidth-30, introducePackingHeight)];
    myLabel.backgroundColor = UIColor.redColor;
    myLabel.numberOfLines = 0;
    myLabel.font = [UIFont systemFontOfSize:fontSize];
    myLabel.textAlignment = NSTextAlignmentLeft;
    myLabel.attributedText = introducePacking;
    //    myLabel.text = text;
    [self.view addSubview:myLabel];
}

@end
