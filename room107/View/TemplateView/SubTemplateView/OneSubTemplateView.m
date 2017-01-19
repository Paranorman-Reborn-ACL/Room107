//
//  OneSubTemplateView.m
//  room107
//
//  Created by 107间 on 16/4/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "OneSubTemplateView.h"
#import "ReddieView.h"
#import "CustomImageView.h"

@interface OneSubTemplateView()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *iconLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) CustomImageView *iconImageView;
@property(nonatomic, strong) ReddieView *redDotView;
@property(nonatomic, strong) NSArray *targetURLs;
@property(nonatomic, strong) NSArray *holdTargetUrl;

@end

@implementation OneSubTemplateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor whiteColor]];
    if (self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        CGFloat originY = (height - 43) / 2;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, width, 15)];
        [_titleLabel setFont:[UIFont room107SystemFontThree]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_titleLabel];
        
        self.subtitleLabel = [[UILabel alloc] init];
        [_subtitleLabel setFont:[UIFont room107SystemFontTwo]];
        [_subtitleLabel setTextColor:[UIColor room107GrayColorE]];
        [self addSubview:_subtitleLabel];
        
        self.iconImageView = [[CustomImageView alloc] init];
        [_iconImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_iconImageView];
        
        self.redDotView= [[ReddieView alloc] initWithOrigin:CGPointMake(0, 0)];
        [_redDotView setHidden:YES];
        [self addSubview:_redDotView];
        
        UIView *tapView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:tapView];
        [tapView setBackgroundColor:[UIColor clearColor]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [tapView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        longPressGestureRec.minimumPressDuration = 0.5f;
        [tapView addGestureRecognizer:longPressGestureRec];
    }
    return self;
}

- (IBAction)tapClick:(id)sender {
    if (_buttonClickHandlerBlock) {
        _buttonClickHandlerBlock(_targetURLs);
    }
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (_buttonDidLongPressHandlerBlock) {
            _buttonDidLongPressHandlerBlock(_holdTargetUrl);
        }
    }
}

- (void)setIconColor:(UIColor *)iconColor {
    [_iconLabel setTextColor:iconColor];
}

- (void)setSubTemplateInfo:(NSDictionary *)dataDict {
    NSNumber *imageType = dataDict[@"imageType"];
    NSString *imageUrl = dataDict[@"imageUrl"];
    NSNumber *reddie = dataDict[@"reddie"];
    NSString *subtext = dataDict[@"subtext"];
    NSString *text = dataDict[@"text"];
    _targetURLs = dataDict[@"targetUrl"];
    _holdTargetUrl = dataDict[@"holdTargetUrl"];
    
    CGFloat originX;
    CGFloat imageWidth = 15.0f;
    CGFloat originY = (self.frame.size.height - imageWidth) / 2;
    
    if (text || ![text isEqualToString:@""]) {
        [_titleLabel setText:text];
        originY = CGRectGetMaxY(_titleLabel.frame) + 11;
    } else {
        [_titleLabel setText:@""];
    }
    
    if (  (imageUrl && ![imageUrl isEqualToString:@""]) && (subtext && ![subtext isEqualToString:@""]) ) {
        //有图有小字
       CGRect contentRect = [subtext boundingRectWithSize:(CGSize){MAXFLOAT, 14} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontTwo]} context:nil];
        originX = (self.frame.size.width - 5 - contentRect.size.width - imageWidth) / 2;
        [_iconImageView setFrame:CGRectMake(originX, originY, imageWidth, imageWidth)];
        [_iconImageView setImageWithURL:imageUrl];
        [_subtitleLabel setFrame:CGRectMake(CGRectGetMaxX(_iconImageView.frame) + 5, originY, contentRect.size.width, 14)];
        [_subtitleLabel setText:subtext];
        
    } else if ( (imageUrl && ![imageUrl isEqualToString:@""]) && (!subtext || [subtext isEqualToString:@""])){
        //有图无小字字
        originX = (self.frame.size.width - imageWidth) / 2;
        [_iconImageView setFrame:CGRectMake(originX, originY, imageWidth, imageWidth)];
        [_iconImageView setImageWithURL:imageUrl];
        
    } else if ( (!imageUrl || [imageUrl isEqualToString:@""]) && (subtext && ![subtext isEqualToString:@""]) ){
        //无图有小字
        CGRect contentRect = [subtext boundingRectWithSize:(CGSize){MAXFLOAT, 14} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontTwo]} context:nil];
        originX = (self.frame.size.width - contentRect.size.width) / 2;
        [_subtitleLabel setFrame:CGRectMake(originX, originY, contentRect.size.width, 14)];
        [_subtitleLabel setBackgroundColor:[UIColor redColor]];
        [_subtitleLabel setText:subtext];
    } else {
        //无图无小字
    }
    
    if ([reddie isEqual:@1]) {
        //有小红点
        [_redDotView setHidden:NO];
        [_redDotView resetOrigin:CGPointMake(CGRectGetMaxX(_subtitleLabel.frame) + 2, CGRectGetMinY(_subtitleLabel.frame) - 4)];
    } else {
        [_redDotView setHidden:YES];
    }
    
    if (imageType && [imageType isEqual:@1]) {
        [_iconImageView setCornerRadius:_iconImageView.frame.size.width / 2];
    } else {
        [_iconImageView setCornerRadius:0];
    }
    
}
@end
