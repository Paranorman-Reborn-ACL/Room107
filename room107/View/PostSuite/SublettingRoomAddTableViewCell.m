//
//  SublettingRoomAddTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SublettingRoomAddTableViewCell.h"
#import "SearchTipLabel.h"
#import "CustomImageView.h"

@interface SublettingRoomAddTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *addRoomlabel;

@end

@implementation SublettingRoomAddTableViewCell

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
        
        CGFloat imageViewWidth = 22;
        CGFloat imageViewY = 20;
        CGFloat imageViewX = (CGRectGetWidth(containerView.bounds) - imageViewWidth) / 2;
        CustomImageView *addImageView = [[CustomImageView alloc] initWithFrame:(CGRect){imageViewX, imageViewY, imageViewWidth, imageViewWidth}];
        [addImageView setImage:[UIImage makeImageFromText:@"\ue62f" font:[UIFont room107FontSix] color:[UIColor room107GreenColor]]];
        [containerView addSubview:addImageView];
        
        CGFloat labelWidth = 100;
        CGFloat labelX = (CGRectGetWidth(containerView.bounds) - labelWidth) / 2;
        CGFloat labelY = imageViewY + CGRectGetHeight(addImageView.bounds) + 15;
        CGFloat labelHeight = 16;
        _addRoomlabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){labelX, labelY, labelWidth, labelHeight}];
        [_addRoomlabel setTextAlignment:NSTextAlignmentCenter];
        [_addRoomlabel setFont:[UIFont room107FontTwo]];
        [_addRoomlabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:_addRoomlabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, sublettingRoomAddTableViewCellHeight);
}

- (void)setLabelText:(NSString *)text {
    [_addRoomlabel setText:text];
}

@end
