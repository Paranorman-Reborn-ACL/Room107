//
//  OnlyTextTableViewCell.m
//  room107
//
//  Created by ningxia on 15/10/10.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "OnlyTextTableViewCell.h"
#import "SearchTipLabel.h"

@interface OnlyTextTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *contentLabel;

@end

@implementation OnlyTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _contentLabel = [[SearchTipLabel alloc] init];
        [self.contentView addSubview:_contentLabel];
    }
    
    return self;
}

- (void)setContent:(NSString *)content andHeight:(CGFloat)height {
    [_contentLabel setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, height)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content ? content : @""];
    [attributedString addAttribute:NSFontAttributeName value:_contentLabel.font range:NSMakeRange(0, content.length)];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:_contentLabel.textColor range:NSMakeRange(0, content.length)];
    [_contentLabel setAttributedText:attributedString];
}

@end
