//
//  AccountCardTableViewCell.m
//  room107
//
//  Created by 107间 on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "AccountCardTableViewCell.h"
#import "IconLabel.h"
#import "SearchTipLabel.h"
#import "NSString+AttributedString.h"
#import "ReddieView.h"

@interface AccountCardTableViewCell()

@property (nonatomic, strong) IconLabel *iconLabel;                //图标
@property (nonatomic, strong) SearchTipLabel *titleTextLabel;      //标题
@property (nonatomic, strong) SearchTipLabel *subtitleTextLabel;   //说明
@property (nonatomic, strong) SearchTipLabel *valueLabel;          //电话 认证状态

@end

@implementation AccountCardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor:[UIColor whiteColor]];
    if (self) {
        CGFloat originX = 11;
        _iconLabel = [[IconLabel alloc] initWithFrame:(CGRect){originX, 0, 30, accountCardTableViewCellHeight}];
        [_iconLabel setFont:[UIFont room107FontFour]];
        [self.contentView addSubview:_iconLabel];
        
        originX += CGRectGetWidth(_iconLabel.bounds);
        _titleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, 75, accountCardTableViewCellHeight}];
        [_titleTextLabel setTextColor:[UIColor room107GrayColorD]];
        [self.contentView addSubview:_titleTextLabel];
        
        originX += CGRectGetWidth(_titleTextLabel.bounds);
        _subtitleTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0 , 80, accountCardTableViewCellHeight}];
        [_subtitleTextLabel setFont:[UIFont room107FontTwo]];
        [self.contentView addSubview:_subtitleTextLabel];
        
        originX += CGRectGetWidth(_subtitleTextLabel.bounds);
        _valueLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){[self cellFrame].size.width - 122, 0, 110, accountCardTableViewCellHeight}];
        [_valueLabel setTextColor:[UIColor room107GrayColorC]];
        [_valueLabel setFont:[UIFont room107SystemFontTwo]];
        [_valueLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_valueLabel];
    }
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, accountCardTableViewCellHeight);
}

- (void)setAccountCardInfo:(NSDictionary *)accountCardInfo {
    [_iconLabel setText:accountCardInfo[@"icon"]];
    [_iconLabel setTextColor:[UIColor colorFromHexString:@"#c9c9c9"]];
    
    [_titleTextLabel setText:accountCardInfo[@"title"]];
    [_subtitleTextLabel setText:accountCardInfo[@"subtitle"]];
    [_valueLabel setText:accountCardInfo[@"value"]];
}

-(void)setTelephone:(NSString *)telephone {
    [_valueLabel setText:telephone];
}


@end
