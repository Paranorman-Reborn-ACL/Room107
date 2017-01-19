//
//  DateShowTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/28.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "DateShowTableViewCell.h"
#import "ThirteenTemplateView.h"

@interface DateShowTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *dateIconLabel;
@property (nonatomic, strong) SearchTipLabel *dateTextLabel;

@end

@implementation DateShowTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        CGFloat originY = 11;
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]);
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){0, originY, viewWidth, CGRectGetHeight([self cellFrame]) - originY}];
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:containerView];
        
        ThirteenTemplateView *titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, viewWidth, 36} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":lang(@"EarliestCheckin")}];
        [containerView addSubview:titleView];
        
        originY = CGRectGetHeight(titleView.bounds);
        CGFloat iconWidth = 22;
        CGFloat spaceX = 11;
        CGFloat labelWidth = 95;
        CGFloat labelHeight = CGRectGetHeight(containerView.bounds) - originY;
        CGFloat originX = (CGRectGetWidth([self cellFrame]) - (iconWidth + spaceX + labelWidth)) / 2;
        _dateIconLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, iconWidth, labelHeight}];
        [_dateIconLabel setText:@"\ue63e"];
        [_dateIconLabel setFont:[UIFont room107FontFour]];
        [containerView addSubview:_dateIconLabel];
        
        originX += iconWidth + spaceX;
        _dateTextLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_dateTextLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:_dateTextLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, dateShowTableViewCellHeight);
}

- (void)setDateShowText:(NSString *)text {
    self.contentView.hidden = text ? [text isEqualToString:@""] ? YES : NO : YES;
    [_dateTextLabel setText:text];
}

@end
