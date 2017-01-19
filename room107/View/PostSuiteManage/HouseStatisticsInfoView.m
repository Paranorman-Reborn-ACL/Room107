//
//  HouseStatisticsInfoView.m
//  room107
//
//  Created by ningxia on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseStatisticsInfoView.h"
#import "SearchTipLabel.h"

@interface HouseStatisticsInfoView ()

@property (nonatomic, strong) SearchTipLabel *textLabel;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;

@end

@implementation HouseStatisticsInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originY = 0;
        CGFloat labelWidth = CGRectGetWidth(frame);
        CGFloat labelHeight = 20;
        
        _textLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, labelWidth, labelHeight}];
        [_textLabel setTextColor:[UIColor room107GrayColorE]];
        [_textLabel setFont:[UIFont room107SystemFontFour]];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setNumberOfLines:1];
        [self addSubview:_textLabel];
        
        originY += CGRectGetHeight(_textLabel.bounds) + 11;
        labelHeight = 15;
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, labelWidth, labelHeight}];
        [_subtextLabel setNumberOfLines:1];
        [self addSubview:_subtextLabel];
    }
    
    return self;
}

- (void)setDataDictionary:(NSDictionary *)dataDic {
    [_textLabel setText:dataDic[@"text"]];
    [_textLabel setTextColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"textColor"]]]];
    
    NSString *subtext = dataDic[@"subtext"] ? dataDic[@"subtext"] : @"";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:subtext];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, subtext.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontIconName size:15.0f] range:NSMakeRange(0, 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorC] range:NSMakeRange(0, 1)];
    if (subtext.length > 1) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontOne] range:NSMakeRange(1, subtext.length - 1)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"subtextColor"]]] range:NSMakeRange(1, subtext.length - 1)];
    }
    [_subtextLabel setAttributedText:attributedString];
}

@end
