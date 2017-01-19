//
//  LicenseAgreementView.m
//  room107
//
//  Created by ningxia on 16/2/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "LicenseAgreementView.h"
#import "SearchTipLabel.h"

@interface LicenseAgreementView ()

@property (nonatomic, strong) SearchTipLabel *contentLabel;
@property (nonatomic, strong) SearchTipLabel *iconLabel;
@property (nonatomic, strong) NSString *content;

@end

@implementation LicenseAgreementView

- (id)initWithFrame:(CGRect)frame withContent:(NSString *)content {
    self = [super initWithFrame:frame];
    
    if (self) {
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){20, 0, frame.size.width - 20, frame.size.height}];
        _content = content;
        [_contentLabel setFont:[UIFont room107SystemFontThree]];
        [_contentLabel setNumberOfLines:0];
        [self addSubview:_contentLabel];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[@"" stringByAppendingString:_content ? _content : @""]];
        [attributedString addAttributes:[self attributes] range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorC] range:NSMakeRange(0, attributedString.length)];
        [_contentLabel setAttributedText:attributedString];
        [_contentLabel setTextAlignment:NSTextAlignmentLeft];
        
        _iconLabel = [[SearchTipLabel alloc] initWithFrame:CGRectMake(0, 0, 20, frame.size.height/2)];
        [_iconLabel setFont:[UIFont room107FontThree]];
        [_iconLabel setText:@"\ue643"];
        [_iconLabel setTextColor:[UIColor room107GrayColorC]];
        [self addSubview:_iconLabel];
        
        UITapGestureRecognizer *tapGestureRecgnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelDidClick)];
        _contentLabel.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapGestureRecgnizer];
    }
    
    return self;
}

- (void)setStatus:(BOOL)selected {
    if (selected) {
        [self labelDidClick];
    }
}

- (BOOL)status {
    return [_contentLabel.textColor isEqual:[UIColor room107GrayColorC]] ? NO : YES;
}

- (void)labelDidClick {
    NSString *text = [@"" stringByAppendingString:_content ? _content : @""];
    UIColor *textColor = [UIColor room107GreenColor];
    [_iconLabel setText:@"\ue644"];
    [_iconLabel setTextColor:[UIColor room107GreenColor]];

    if ([_contentLabel.textColor isEqual:[UIColor room107GreenColor]]) {
        text = [@"" stringByAppendingString:_content ? _content : @""];
        textColor = [UIColor room107GrayColorC];
        [_iconLabel setText:@"\ue643"];
        [_iconLabel setTextColor:[UIColor room107GrayColorC]];
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttributes:[self attributes] range:NSMakeRange(0, text.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, text.length)];
    [_contentLabel setAttributedText:attributedString];
    [_contentLabel setTextAlignment:NSTextAlignmentLeft];
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:_contentLabel.font,
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    return attributes;
}

@end
