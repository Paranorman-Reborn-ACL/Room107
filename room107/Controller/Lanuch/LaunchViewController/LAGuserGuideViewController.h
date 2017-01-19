//
//  LAGuserGuideViewController.h
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAGuserGuideViewController : Room107ViewController

@property (nonatomic, copy) void(^loginHandler)();

- (void)setLookButtonDidClickedHandler:(void(^)())handler;
@end
