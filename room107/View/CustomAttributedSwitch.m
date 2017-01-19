//
//  CustomAttributedSwitch.m
//  room107
//
//  Created by 107间 on 15/11/13.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "CustomAttributedSwitch.h"

@implementation CustomAttributedSwitch

- (id)initWithFrame:(CGRect)frame stringsArray:(NSArray *)strings {
    self = [(CustomAttributedSwitch *)[DVSwitch alloc] initWithAttributedStringsArray:strings];
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


@end
