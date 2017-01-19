//
//  Room107TableView.m
//  room107
//
//  Created by ningxia on 15/7/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableView.h"

@implementation Room107TableView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag | UIScrollViewKeyboardDismissModeInteractive;//让键盘可以在滚动的时候消失
    }
    
    return self;
}

@end
