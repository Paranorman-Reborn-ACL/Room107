//
//  DividingLineView.m
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "DividingLineView.h"

@implementation DividingLineView

- (id)initWithFrame:(CGRect)frame {
    frame.size.height = 0.5f;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor room107GrayColorA]];
    }
    
    return self;
}

@end
