//
//  HomeCardTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HomeCardTableViewCell.h"
#import "IconLabel.h"
#import "SearchTipLabel.h"
#import "NSString+AttributedString.h"
#import "ReddieView.h"

@interface HomeCardTableViewCell ()

@property (nonatomic, strong) IconLabel *iconLabel;
@property (nonatomic, strong) SearchTipLabel *titleLabel;
@property (nonatomic, strong) SearchTipLabel *subtitleLabel;
@property (nonatomic, strong) SearchTipLabel *valueLabel;
@property (nonatomic, strong) ReddieView *flagView;

@end

@implementation HomeCardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 22;
        _iconLabel = [[IconLabel alloc] initWithFrame:(CGRect){originX, 0, 28, homeCardTableViewCellHeight}];
        [_iconLabel setFont:[UIFont room107FontThree]];
        [self.contentView addSubview:_iconLabel];
        
        originX += CGRectGetWidth(_iconLabel.bounds);
        _titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, homeCardTableViewCellHeight, homeCardTableViewCellHeight}];
        [_titleLabel setTextColor:[UIColor room107GrayColorD]];
        [self.contentView addSubview:_titleLabel];
        
        originX += CGRectGetWidth(_titleLabel.bounds);
        _subtitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, homeCardTableViewCellHeight, homeCardTableViewCellHeight}];
        [_subtitleLabel setFont:[UIFont room107FontTwo]];
        [self.contentView addSubview:_subtitleLabel];
        
        originX += CGRectGetWidth(_subtitleLabel.bounds);
        _valueLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, homeCardTableViewCellHeight, homeCardTableViewCellHeight}];
        [_valueLabel setTextColor:[UIColor room107GrayColorD]];
        [_valueLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_valueLabel];
        
        //未读标示
        _flagView = [[ReddieView alloc] initWithOrigin:CGPointMake(CGRectGetWidth([self cellFrame]) - 17, 15)];
        [self.contentView addSubview:_flagView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, homeCardTableViewCellHeight);
}

- (void)setAnotherCardInfo:(NSDictionary *)card {
    [_iconLabel setText:[CommonFuncs iconCodeByHexStr:[card[@"values"] count] > 0 ? card[@"values"][0] : @""]];
    [_iconLabel setTextColor:[UIColor colorFromHexString:[@"#" stringByAppendingString:card[@"values"][1] ? card[@"values"][1] : @""]]];
    
    CGFloat maxWidth = CGRectGetWidth([self cellFrame]) / 2;
    //计算第一行文字的宽度
    NSString *title = [card[@"values"] count] > 2 ? card[@"values"][2] : @"";
    CGRect contentRect = [title boundingRectWithSize:(CGSize){maxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil];
    [_titleLabel setFrame:(CGRect){_titleLabel.frame.origin, contentRect.size.width, homeCardTableViewCellHeight}];
    [_titleLabel setText:title];
    
    NSString *valueString = [card[@"values"] count] > 5 ? card[@"values"][5] : @"";
    if (![valueString isEqualToString:@""]) {
        contentRect = [valueString boundingRectWithSize:(CGSize){maxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107FontThree]} context:nil];
        [_valueLabel setFrame:(CGRect){CGRectGetWidth([self cellFrame]) - 22 - contentRect.size.width, _valueLabel.frame.origin.y, contentRect.size.width + 5, homeCardTableViewCellHeight}];
        if (![card[@"values"][4] isEqualToString:@""]) {
            NSString *addStr = [NSString stringWithFormat:@"%@%@", card[@"values"][4], valueString];
            NSMutableAttributedString *attrValue = [NSString attributedStringFromPriceStr:addStr andPriceFont:[UIFont room107FontThree] andPriceColor:_valueLabel.textColor andUnitFont:[UIFont fontWithName:fontIconName size:10.0f] andUnitColor:_valueLabel.textColor];
            [_valueLabel setAttributedText:attrValue];
            [_valueLabel setFrame:(CGRect){CGRectGetWidth([self cellFrame]) - 42 - contentRect.size.width, _valueLabel.frame.origin.y, contentRect.size.width + 25, homeCardTableViewCellHeight}];
        } else {
            [_valueLabel setText:valueString];
        }
    } else {
        [_valueLabel setText:@""];
    }
    
    _flagView.hidden = [card[@"values"] count] > 6 ? ![card[@"values"][6] boolValue] : YES;

    NSString *subtitle = [card[@"values"] count] > 3 ? card[@"values"][3] : @"";
    contentRect = [subtitle boundingRectWithSize:(CGSize){maxWidth, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_subtitleLabel.font} context:nil];
    CGFloat originX = _titleLabel.frame.origin.x + _titleLabel.frame.size.width + 10;
    [_subtitleLabel setFrame:(CGRect){originX, _subtitleLabel.frame.origin.y, MIN(contentRect.size.width, _valueLabel.frame.origin.x - originX), homeCardTableViewCellHeight}];
    [_subtitleLabel setText:subtitle];
}

@end
