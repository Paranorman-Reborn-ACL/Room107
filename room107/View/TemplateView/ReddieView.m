//
//  ReddieView.m
//  room107
//
//  Created by ningxia on 15/10/26.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "ReddieView.h"

@implementation ReddieView

- (id)initWithOrigin:(CGPoint)origin {
    CGFloat viewWidth = 8;
    self = [super initWithFrame:(CGRect){origin, viewWidth, viewWidth}];
    
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        self.layer.cornerRadius = viewWidth / 2;
    }
    
    return self;
}

- (void)resetOrigin:(CGPoint)origin {
    CGFloat viewWidth = 8;
    [self setFrame:(CGRect){origin, viewWidth, viewWidth}];
}

@end
