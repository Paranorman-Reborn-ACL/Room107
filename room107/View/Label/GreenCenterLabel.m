//
//  GreenCenterLabel.m
//  room107
//
//  Created by ningxia on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "GreenCenterLabel.h"

@implementation GreenCenterLabel

- (id)initWithFrame:(CGRect)frame withText:(NSString *)text {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTextColor:[UIColor room107GreenColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setText:text];
    }
    
    return self;
}

@end
