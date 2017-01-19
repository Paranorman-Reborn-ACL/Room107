//
//  LandlordHouseInfoView.m
//  room107
//
//  Created by ningxia on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "LandlordHouseInfoView.h"
#import "SearchTipLabel.h"
#import "HouseStatisticsInfoView.h"

@interface LandlordHouseInfoView ()

@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) SearchTipLabel *textLabel;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;
@property (nonatomic, strong) UIView *subtextView;
@property (nonatomic, strong) UIView *rightLineView;
@property (nonatomic, strong) HouseStatisticsInfoView *pushNumberView;
@property (nonatomic, strong) HouseStatisticsInfoView *viewNumberView;
@property (nonatomic, strong) HouseStatisticsInfoView *interestNumberView;
@property (nonatomic, strong) HouseStatisticsInfoView *requestNumberView;

@end

@implementation LandlordHouseInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat originX = 0;
        CGFloat lineViewHeight = 0.5;
        CGFloat labelHeight = 16;
        CGFloat lineY = (labelHeight - lineViewHeight) / 2;
        _leftLineView = [[UIView alloc] initWithFrame:(CGRect){originX, lineY, 0, lineViewHeight}];
        [_leftLineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:_leftLineView];
        
        CGFloat originY = 0;
        _textLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        [_textLabel setTextColor:[UIColor room107GrayColorD]];
        [_textLabel setFont:[UIFont room107SystemFontThree]];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setNumberOfLines:1];
        [self addSubview:_textLabel];
        
        _subtextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, 0, labelHeight}];
        //描边
        _subtextLabel.layer.borderWidth = 0.5f;
        _subtextLabel.layer.borderColor = [UIColor room107GreenColor].CGColor;
        [_subtextLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextLabel setTextAlignment:NSTextAlignmentCenter];
        [_subtextLabel setTextColor:[UIColor room107GreenColor]];
        [_subtextLabel setNumberOfLines:1];
        [self addSubview:_subtextLabel];
        
        _subtextView = [[UIView alloc] initWithFrame:(CGRect){0, originY, 3, labelHeight}];
        [_subtextView setBackgroundColor:[UIColor room107GreenColor]];
        [self addSubview:_subtextView];
        
        _rightLineView = [[UIView alloc] initWithFrame:(CGRect){0, lineY, 0, lineViewHeight}];
        [_rightLineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:_rightLineView];
        
        originY += CGRectGetHeight(_textLabel.bounds) + 25;
        CGSize houseStatisticsInfoViewSize = CGSizeMake((CGRectGetWidth(frame) - 2 * originX) / 4, 46);
        _pushNumberView = [[HouseStatisticsInfoView alloc] initWithFrame:(CGRect){originX, originY, houseStatisticsInfoViewSize}];
        [self addSubview:_pushNumberView];
        
        originX += houseStatisticsInfoViewSize.width;
        _viewNumberView = [[HouseStatisticsInfoView alloc] initWithFrame:(CGRect){originX, originY, houseStatisticsInfoViewSize}];
        [self addSubview:_viewNumberView];
        
        originX += houseStatisticsInfoViewSize.width;
        _interestNumberView = [[HouseStatisticsInfoView alloc] initWithFrame:(CGRect){originX, originY, houseStatisticsInfoViewSize}];
        [self addSubview:_interestNumberView];
        
        originX += houseStatisticsInfoViewSize.width;
        _requestNumberView = [[HouseStatisticsInfoView alloc] initWithFrame:(CGRect){originX, originY, houseStatisticsInfoViewSize}];
        [self addSubview:_requestNumberView];
    }
    
    return self;
}

- (void)setInfoDataDictionary:(NSDictionary *)dataDic {
    NSString *text = dataDic[@"text"] ? dataDic[@"text"] : @"";
    NSString *subtext = dataDic[@"subtext"] ? dataDic[@"subtext"] : @"";
    
    CGFloat originX = 0;
    CGFloat textMaxWidth = CGRectGetWidth(self.bounds) - 2 * originX;
    //计算文字的宽度
    CGFloat textLabelWidth = [text boundingRectWithSize:(CGSize){textMaxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textLabel.font} context:nil].size.width;
    CGFloat subtextLabelWidth = [subtext boundingRectWithSize:(CGSize){textMaxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_subtextLabel.font} context:nil].size.width + 10;
    CGFloat lineViewWidth = (textMaxWidth - 5 - textLabelWidth - 5 - subtextLabelWidth - CGRectGetWidth(_subtextView.bounds) - 5) / 2;
    CGRect viewFrame = _leftLineView.frame;
    viewFrame.size.width = lineViewWidth;
    [_leftLineView setFrame:viewFrame];
    
    CGRect textLabelFrame = _textLabel.frame;
    originX += CGRectGetWidth(_leftLineView.bounds) + 5;
    textLabelFrame.origin.x = originX;
    textLabelFrame.size.width = textLabelWidth;
    [_textLabel setFrame:textLabelFrame];
    [_textLabel setText:dataDic[@"text"]];
    
    textLabelFrame = _subtextLabel.frame;
    originX += CGRectGetWidth(_textLabel.bounds) + 5;
    textLabelFrame.origin.x = originX;
    textLabelFrame.size.width = subtextLabelWidth;
    [_subtextLabel setFrame:textLabelFrame];
    [_subtextLabel setText:dataDic[@"subtext"]];
    
    viewFrame = _subtextView.frame;
    originX += CGRectGetWidth(_subtextLabel.bounds);
    viewFrame.origin.x = originX;
    [_subtextView setFrame:viewFrame];
    
    viewFrame = _rightLineView.frame;
    originX += CGRectGetWidth(_subtextView.bounds) + 5;
    viewFrame.origin.x = originX;
    viewFrame.size.width = lineViewWidth;
    [_rightLineView setFrame:viewFrame];
    
    //houseStatus房间状态，0表示审核中，1表示审核失败，2表示对外出租，3暂不对外，4租住中
    NSString *textColor = @"c9c9c9";
    NSString *subtextColor = @"c9c9c9";
    if (dataDic[@"houseStatus"] && [dataDic[@"houseStatus"] isEqual:@2]) {
        textColor = @"494949";
        subtextColor = @"797979";
    }
    [_pushNumberView setDataDictionary:@{@"text":[dataDic[@"pushNumber"] stringValue], @"textColor":textColor, @"subtext":[@"\ue677 " stringByAppendingString:lang(@"Push")], @"subtextColor":subtextColor}];
    [_viewNumberView setDataDictionary:@{@"text":[dataDic[@"viewNumber"] stringValue], @"textColor":textColor, @"subtext":[@"\ue659 " stringByAppendingString:lang(@"Browse")], @"subtextColor":subtextColor}];
    [_interestNumberView setDataDictionary:@{@"text":[dataDic[@"interestNumber"] stringValue], @"textColor":textColor, @"subtext":[@"\ue646 " stringByAppendingString:lang(@"Collect")], @"subtextColor":subtextColor}];
    [_requestNumberView setDataDictionary:@{@"text":[dataDic[@"requestNumber"] stringValue], @"textColor":textColor, @"subtext":[@"\ue689 " stringByAppendingString:lang(@"Apply")], @"subtextColor":subtextColor}];
}

@end
