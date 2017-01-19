//
//  SuiteSearchFromSubwayViewController.h
//  room107
//
//  Created by 107间 on 16/1/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107ViewController.h"
@class SuiteSearchFromSubwayViewController;

@protocol SuiteSearchFromSubwayViewDelegate <NSObject>

@optional

- (void)suiteSearchFromSubwayShouldReturnOrSearchButton:(NSString *)position;
- (void)suiteSearchFromSubwayShouldTappedOnTagPosition:(NSString *)tagPosition atIndex:(NSInteger)index;
- (void)suiteSearchFromSubwayDidSelectedOnSubwayLine:(NSString *)subwayLine andSubwayStation:(NSString *)subwayStation;
- (void)suiteSearchFromSubwayDidSelectedWithKeyword:(NSString *)keyword;

@end

@interface SuiteSearchFromSubwayViewController : Room107ViewController

@property (nonatomic, weak) id<SuiteSearchFromSubwayViewDelegate> delegate;

@end
