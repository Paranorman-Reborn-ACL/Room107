//
//  CustomSwitch.m
//  room107
//
//  Created by ningxia on 15/7/4.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "CustomSwitch.h"

@implementation CustomSwitch

- (id)initWithFrame:(CGRect)frame stringsArray:(NSArray *)strings {
    self = (CustomSwitch *)[DVSwitch switchWithStringsArray:strings];
    if (self) {
        self.frame = frame;
        self.sliderOffset = 1.0;
        self.cornerRadius = CGRectGetHeight(self.bounds) / 2;
        self.fontInside = [UIFont room107FontThree];
        self.fontOutside = [UIFont room107FontThree];
        self.labelTextColorOutsideSlider = [UIColor room107GrayColorC];
        self.labelTextColorInsideSlider = [UIColor room107GreenColor];
        self.backgroundColor = [UIColor room107GrayColorB];
        self.sliderColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
