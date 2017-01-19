//
//  ProofOfLeaseQualificationsView.m
//  room107
//
//  Created by ningxia on 15/10/21.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "ProofOfLeaseQualificationsView.h"
#import "YellowTextTipsLabel.h"
#import "CustomImageView.h"

@implementation ProofOfLeaseQualificationsView

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSString *)title andImageName:(NSString *)imageName {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 22.0f;
        CGFloat originY = 10;
        CGFloat viewWidth = CGRectGetWidth(self.frame) - 2 * originX;
        CGRect frame = (CGRect){originX, originY, viewWidth, 20};
        YellowTextTipsLabel *titleLabel = [[YellowTextTipsLabel alloc] initWithFrame:frame withTitle:title];
        [self addSubview:titleLabel];
        
        frame.origin.y = CGRectGetHeight(titleLabel.bounds) + originY + 10;
        frame.size.height = CGRectGetHeight(self.frame) - frame.origin.y - 30;
        CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:frame];
        [imageView setImageWithName:imageName];
        [self addSubview:imageView];
    }
    
    return self;
}

@end
