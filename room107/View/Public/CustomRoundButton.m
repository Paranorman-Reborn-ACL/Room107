//
//  CustomRoundButton.m
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CustomRoundButton.h"

@implementation CustomRoundButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setCornerRadius:CGRectGetHeight(frame) / 2];
        [self addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)setBackgroundImageWithName:(NSString *)name {
    [self setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}

//该方法可被子类override重写（覆盖），以实现不同的功能
- (IBAction)buttonDidClick:(id)sender {
    
}

@end
