//
//  FourSubTemplateView.m
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "FourSubTemplateView.h"
#import "CustomImageView.h"
#import "SearchTipLabel.h"
#import "ReddieView.h"
#import "NSString+Encoded.h"

@interface FourSubTemplateView ()

@property (nonatomic, strong) CustomImageView *customImageView;
@property (nonatomic, strong) SearchTipLabel *textLabel;
@property (nonatomic, strong) ReddieView *reddieView;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;
@property (nonatomic, strong) NSArray *targetURLs;
@property (nonatomic, strong) void (^viewDidClickHandlerBlock)(NSArray *targetURLs);

@end

@implementation FourSubTemplateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat originX = 16;
        CGFloat imageViewWidth = 44;
        CGFloat imageViewHeight = 44;
        CGFloat originY = (CGRectGetHeight(frame) - imageViewHeight) / 2;
        
        _customImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, imageViewWidth, imageViewHeight}];
        [self addSubview:_customImageView];
        
        CGFloat spaceX = 11;
        originX += CGRectGetWidth(_customImageView.bounds) + spaceX;
        originY += 2;
        CGFloat labelWidth = CGRectGetWidth(frame) - originX - spaceX;
        CGFloat labelHeight = 20;
        _textLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_textLabel setTextColor:[UIColor room107GrayColorE]];
        [_textLabel setFont:[UIFont room107SystemFontThree]];
        [_textLabel setNumberOfLines:1];
        [self addSubview:_textLabel];
        
        //未读标示
        _reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(originX, originY - 2)];
        [self addSubview:_reddieView];
        
        originY += CGRectGetHeight(_textLabel.bounds) + 8;
        labelHeight = 12;
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_subtextLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextLabel setNumberOfLines:1];
        [self addSubview:_subtextLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidClick:)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (IBAction)viewDidClick:(id)sender {
    if (_viewDidClickHandlerBlock) {
        _viewDidClickHandlerBlock(_targetURLs ? _targetURLs : @[]);
    }
}

- (void)setTemplateDataDictionary:(NSDictionary *)dataDic {
    _customImageView.hidden = NO;
    [_customImageView setCornerRadius:0];
    if ([dataDic[@"imageType"] isEqual:@1]) {
        [_customImageView setCornerRadius:CGRectGetHeight(_customImageView.bounds) / 2];
    }
    CGFloat originX = _customImageView.frame.origin.x;
    if (dataDic[@"imageUrl"] && ![dataDic[@"imageUrl"] isEqualToString:@""]) {
        originX += CGRectGetWidth(_customImageView.bounds) + 11;
        _customImageView.hidden = NO;
    }
    CGFloat labelWidth = CGRectGetWidth(self.frame) - originX;
    CGRect labelFrame = _textLabel.frame;
    labelFrame.origin.x = originX;
    labelFrame.size.width = labelWidth;
    [_textLabel setFrame:labelFrame];
    labelFrame = _subtextLabel.frame;
    labelFrame.origin.x = originX;
    labelFrame.size.width = labelWidth;
    [_subtextLabel setFrame:labelFrame];
    [_customImageView setImageWithURL:dataDic[@"imageUrl"]];
    [_textLabel setText:dataDic[@"text"]];
    [_subtextLabel setText:dataDic[@"subtext"]];
    _targetURLs = dataDic[@"targetUrl"];
    
    _reddieView.hidden = ![dataDic[@"reddie"] boolValue];
    if (dataDic[@"text"] && [dataDic[@"reddie"] boolValue]) {
        CGRect frame = _reddieView.frame;
        //计算文字的宽度
        CGRect contentRect = [dataDic[@"text"] boundingRectWithSize:(CGSize){CGRectGetWidth(_textLabel.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textLabel.font} context:nil];
        frame.origin.x = _textLabel.frame.origin.x + contentRect.size.width;
        [_reddieView setFrame:frame];
    }
}

- (void)setViewDidClickHandler:(void(^)(NSArray *targetURLs))handler {
    _viewDidClickHandlerBlock = handler;
}

@end
