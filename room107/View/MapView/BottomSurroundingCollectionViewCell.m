//
//  BottomSurroundingCollectionViewCell.m
//  room107
//
//  Created by 107间 on 16/2/17.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "BottomSurroundingCollectionViewCell.h"

@interface BottomSurroundingCollectionViewCell()
@property (nonatomic, strong) UILabel *circleLabel;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation BottomSurroundingCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    if (self) {
        CGFloat originX = 0.0f;
        CGFloat originY = 11.0f;
        CGFloat diameter = 22.0f;
        self.circleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, diameter, diameter)];
        [_circleLabel setBackgroundColor:[UIColor room107GrayColorC]];
        [_circleLabel setFont:[UIFont room107FontTwo]];
        [_circleLabel setTextColor:[UIColor whiteColor]];
        [_circleLabel setTextAlignment:NSTextAlignmentCenter];
        _circleLabel.layer.cornerRadius = diameter/2;
        _circleLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_circleLabel];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(-11, CGRectGetMaxY(_circleLabel.frame) + 11 , frame.size.width + 22, 10)];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setTextColor:[UIColor room107GrayColorC]];
        [_textLabel setFont:[UIFont room107SystemFontOne]];
        [self.contentView addSubview:_textLabel];
    }
    return self;
}

- (void)setCellSelected {
    [_circleLabel setBackgroundColor:[UIColor room107GreenColor]];
    [_textLabel setTextColor:[UIColor room107GreenColor]];
}

- (void)setCellDeSelected {
    [_circleLabel setBackgroundColor:[UIColor room107GrayColorC]];
    [_textLabel setTextColor:[UIColor room107GrayColorC]];
}

- (void)setIcon:(NSString *)icon text:(NSString *)text {
    [_circleLabel setText:icon];
    [_textLabel setText:text];
}

@end
