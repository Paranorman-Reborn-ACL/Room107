//
//  SeparatedView.m
//  room107
//
//  Created by ningxia on 16/2/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SeparatedView.h"

@implementation SeparatedView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat originX = 22;
        CGFloat originY = 0;
        CGFloat lineWidth = (CGRectGetWidth(frame) - 2 * originX * 2 - 5 * 2 - 4) / 2;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){2 * originX, originY, lineWidth, 1}];
        [lineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:lineView];
        
        UIView *dotView = [[UIView alloc] initWithFrame:(CGRect){2 * originX + lineWidth + 5, originY - 1.5, 4, 4}];
        dotView.layer.cornerRadius = CGRectGetHeight(dotView.bounds) / 2;
        dotView.layer.masksToBounds = YES;
        [dotView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:dotView];
        
        lineView = [[UIView alloc] initWithFrame:(CGRect){2 * originX + lineWidth + 2 * 5 + 4, originY, lineWidth, 1}];
        [lineView setBackgroundColor:[UIColor room107GrayColorC]];
        [self addSubview:lineView];
    }
    
    return self;
}

@end
