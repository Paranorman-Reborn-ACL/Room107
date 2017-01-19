//
//  SuiteProfileBriefView.h
//  room107
//
//  Created by ningxia on 15/12/1.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuiteProfileBriefView : UIView

- (void)setHouseInfo:(NSString *)houseInfo;
- (void)setPosition:(NSString *)position;
- (void)setOfflinePrice:(NSNumber *)offlinePrice onlinePrice:(NSNumber *)onlinePrice;

@end
