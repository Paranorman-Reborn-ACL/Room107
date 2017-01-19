//
//  SevenTemplateView.m
//  room107
//
//  Created by ningxia on 16/4/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SevenTemplateView.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "ReddieView.h"

@interface SevenTemplateView ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *textLabel;
@property (nonatomic, strong) ReddieView *reddieView;

@end

@implementation SevenTemplateView

- (id)initWithFrame:(CGRect)frame andTemplateDataDictionary:(NSDictionary *)dataDic {
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat imageViewWidth = 22;
        CGFloat imageViewHeight = 22;
        CGFloat originY = (CGRectGetHeight(frame) - imageViewHeight) / 2;
        
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, originY, imageViewWidth, imageViewHeight}];
        [_customImageView setCornerRadius:imageViewHeight / 2];
        [self addSubview:_customImageView];
        
        originY = 0;
        CGFloat labelHeight = CGRectGetHeight(frame);
        _textLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_textLabel setFont:[UIFont room107FontThree]];
        [_textLabel setTextColor:[UIColor room107GrayColorD]];
        [_textLabel setNumberOfLines:1];
        [self addSubview:_textLabel];
        
        _reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(0, 12)];
        [self addSubview:_reddieView];
        
        if (dataDic) {
            [self setTemplateDataDictionary:dataDic];
        }
    }
    
    return self;
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    _customImageView.hidden = NO;
    [_customImageView setCornerRadius:0];
    if ([dataDic[@"imageType"] isEqual:@1]) {
        [_customImageView setCornerRadius:CGRectGetHeight(_customImageView.bounds) / 2];
    }
    
    CGFloat originX = 11;
    CGFloat imageViewWidth = CGRectGetWidth(_customImageView.bounds) + 11;
    CGFloat labelMaxWidth = CGRectGetWidth(self.bounds) - 2 * originX - imageViewWidth;
    if (!dataDic[@"imageUrl"] || [dataDic[@"imageUrl"] isEqualToString:@""]) {
        if (dataDic[@"imageCode"] && ![dataDic[@"imageCode"] isEqualToString:@""]) {
            _customImageView.hidden = NO;
            [_customImageView setImage:[UIImage makeImageFromText:dataDic[@"imageCode"] font:[UIFont room107FontFour] color:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"textColor"]]]]];
            _customImageView.contentMode = UIViewContentModeCenter;
            originX += CGRectGetWidth(_customImageView.bounds) + 5;
        } else {
            _customImageView.hidden = YES;
            labelMaxWidth = CGRectGetWidth(self.bounds) - 2 * originX;
            imageViewWidth = 0;
        }
    }
    
    //计算文字的宽度
    CGRect textLabelRect = [dataDic[@"text"] ? dataDic[@"text"] : @"" boundingRectWithSize:(CGSize){labelMaxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textLabel.font} context:nil];
    originX = (CGRectGetWidth(self.bounds) - imageViewWidth - textLabelRect.size.width) / 2;
    
    CGRect imageViewFrame = _customImageView.frame;
    imageViewFrame.origin.x = originX;
    [_customImageView setFrame:imageViewFrame];
    
    CGRect labelFrame = _textLabel.frame;
    labelFrame.origin.x = originX + imageViewWidth;
    labelFrame.size.width = textLabelRect.size.width;
    [_textLabel setFrame:labelFrame];
    
    [_customImageView setImageWithURL:dataDic[@"imageUrl"]];
    [_textLabel setText:dataDic[@"text"]];
    if (dataDic[@"textColor"]) {
        [_textLabel setTextColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:dataDic[@"textColor"]]]];
    }
    
    _reddieView.hidden = ![dataDic[@"reddie"] boolValue];
    if (dataDic[@"text"] && [dataDic[@"reddie"] boolValue]) {
        CGRect frame = _reddieView.frame;
        frame.origin.x = _textLabel.frame.origin.x + textLabelRect.size.width;
        [_reddieView setFrame:frame];
    }
}

@end
