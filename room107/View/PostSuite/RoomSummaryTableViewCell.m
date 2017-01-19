//
//  RoomSummaryTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomSummaryTableViewCell.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"

static NSUInteger labelTag = 1000;

@interface RoomSummaryTableViewCell ()

@property (nonatomic, strong) CustomImageView *coverImageView;
//@property (nonatomic, strong) SearchTipLabel *roomNameLabel;
//@property (nonatomic, strong) SearchTipLabel *areaLabel;
//@property (nonatomic, strong) SearchTipLabel *orientationLabel;

@end

@implementation RoomSummaryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11;
        CGFloat originY = 5;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth([self cellFrame]) - 2 * originX, CGRectGetHeight([self cellFrame]) - originY}];
        [containerView setBackgroundColor:[UIColor room107GrayColorB]];
        containerView.layer.cornerRadius = 4;
        containerView.layer.masksToBounds = YES;
        [self addSubview:containerView];
        
        CGFloat imageViewWidth = 50;
        CGFloat imageViewY = 15;
        CGFloat imageViewX = CGRectGetWidth(containerView.bounds) - imageViewWidth - imageViewY;
        _coverImageView = [[CustomImageView alloc] initWithFrame:(CGRect){imageViewX, imageViewY, imageViewWidth, imageViewWidth}];
        [_coverImageView setCornerRadius:2];
        [containerView addSubview:_coverImageView];
        
        CGFloat lineViewX = imageViewX - imageViewY - 0.5;
        CGFloat lineViewY = 10;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){lineViewX, lineViewY, 0.5, CGRectGetHeight(containerView.bounds) - 2 * lineViewY}];
        [lineView setBackgroundColor:[UIColor whiteColor]];
        [containerView addSubview:lineView];
        
        CGFloat labelX = 0;
        CGFloat labelY = 20;
        CGFloat labelWidth = lineViewX / 3;
        CGFloat labelHeight = CGRectGetHeight(containerView.bounds) - 2 * labelY;
        for (NSUInteger i = 0; i < 3; i++) {
            SearchTipLabel *roomlabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){labelX + i * labelWidth, labelY, labelWidth, labelHeight}];
            roomlabel.tag = labelTag + i;
            [roomlabel setFont:[UIFont room107FontThree]];
            [roomlabel setTextColor:[UIColor room107GrayColorD]];
            [roomlabel setTextAlignment:NSTextAlignmentCenter];
            [containerView addSubview:roomlabel];
        }
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, roomSummaryTableViewCellHeight);
}

- (void)setCoverImageURL:(NSString *)url {
    [_coverImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"uploadDefault.png"]];
}

- (void)setRoomType:(NSNumber *)type {
    [self viewWithTag:labelTag].hidden = !type;
    [(SearchTipLabel *)[self viewWithTag:labelTag] setText:[type isEqual:@1] ? lang(@"MasterBedroom") : lang(@"SecondaryBedroom")];
}

- (void)setArea:(NSNumber *)area {
    [self viewWithTag:labelTag + 1].hidden = !area;
    [(SearchTipLabel *)[self viewWithTag:labelTag + 1] setText:[NSString stringWithFormat:@"%@m²", area]];
}

- (void)setOrientation:(NSString *)orientation {
    [self viewWithTag:labelTag + 2].hidden = !orientation;
    [(SearchTipLabel *)[self viewWithTag:labelTag + 2] setText:[NSString stringWithFormat:@"%@%@", [lang(@"Orientation") substringToIndex:1], orientation]];
}

@end
