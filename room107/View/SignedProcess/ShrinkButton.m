//
//  ShrinkButton.m
//  room107
//
//  Created by ningxia on 15/8/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ShrinkButton.h"

@implementation ShrinkButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setTitle:@"\ue629" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor room107GrayColorC] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont room107FontThree]];
    }
    
    return self;
}

- (IBAction)buttonDidClick:(id)sender {
    if ([self.titleLabel.text isEqualToString:@"\ue629"]) {
        [self setTitle:@"\ue62a" forState:UIControlStateNormal];
    } else {
        [self setTitle:@"\ue629" forState:UIControlStateNormal];
    }
}

- (void)setButtonShrink:(BOOL)shrink {
    [self setTitle:shrink ? @"\ue629" : @"\ue62a" forState:UIControlStateNormal];
}

@end
