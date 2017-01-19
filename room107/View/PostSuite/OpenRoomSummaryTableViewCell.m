//
//  OpenRoomSummaryTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OpenRoomSummaryTableViewCell.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"
#import "NSString+AttributedString.h"

static NSUInteger labelTag = 1000;

@interface OpenRoomSummaryTableViewCell ()

@property (nonatomic, strong) CustomImageView *coverImageView;
@property (nonatomic, strong) SearchTipLabel *priceLabel;

@end

@implementation OpenRoomSummaryTableViewCell

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
        
        originY += 5;
        CGFloat lineViewX = (CGRectGetWidth(containerView.bounds) - 0.5) / 2;
        CGFloat lineViewHeight = 20;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){lineViewX, originY, 0.5, lineViewHeight}];
        [lineView setBackgroundColor:[UIColor whiteColor]];
        [containerView addSubview:lineView];
        
        CGFloat labelWidth = 60;
        CGFloat priceWidth = containerView.frame.size.width/2;
        _priceLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){lineViewX - priceWidth - 5, originY, priceWidth, lineViewHeight}];
        [_priceLabel setFont:[UIFont room107FontThree]];
        [_priceLabel setTextColor:[UIColor room107GrayColorD]];
        [_priceLabel setTextAlignment:NSTextAlignmentRight];
        [containerView addSubview:_priceLabel];
        
        SearchTipLabel *statusLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){lineViewX + 5, originY, labelWidth, lineViewHeight}];
        [statusLabel setText:lang(@"Open")];
        [statusLabel setFont:[UIFont room107FontThree]];
        [statusLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:statusLabel];
        
        originY += lineViewHeight + 5;
        CGFloat imageViewWidth = 50;
        CGFloat imageViewRight = 15;
        CGFloat imageViewX = CGRectGetWidth(containerView.bounds) - imageViewWidth - imageViewRight;
        _coverImageView = [[CustomImageView alloc] initWithFrame:(CGRect){imageViewX, originY + 5, imageViewWidth, imageViewWidth}];
        [_coverImageView setCornerRadius:2];
        [containerView addSubview:_coverImageView];
        
        lineViewX = imageViewX - imageViewRight - 0.5;
        CGFloat lineBottom = 10;
        lineView = [[UIView alloc] initWithFrame:(CGRect){lineViewX, originY, 0.5, CGRectGetHeight(containerView.bounds) - originY - lineBottom}];
        [lineView setBackgroundColor:[UIColor whiteColor]];
        [containerView addSubview:lineView];
        
        CGFloat labelX = 0;
        CGFloat labelY = originY + 5;
        labelWidth = lineViewX / 3;
        CGFloat labelHeight = CGRectGetHeight(containerView.bounds) - labelY - lineBottom;
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
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, openRoomSummaryTableViewCellHeight);
}

- (void)setPrice:(NSNumber *)price {
    if (price) {
        CGFloat unitFontSize = 8.0f;
        CGFloat priceFontSize = 20.0f;
        
        NSMutableAttributedString *attributedString = [NSString attributedStringFromPriceStr:[NSString stringWithFormat:@"￥%@", price] andPriceFont:[UIFont systemFontOfSize:priceFontSize] andPriceColor:[UIColor room107GrayColorD] andUnitFont:[UIFont systemFontOfSize:unitFontSize] andUnitColor:[UIColor room107GrayColorD]];
        [_priceLabel setAttributedText:attributedString];
    }
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
