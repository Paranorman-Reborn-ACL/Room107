//
//  SuiteImageTableViewCell.h
//  room107
//
//  Created by ningxia on 15/11/27.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
#import "SDCycleScrollView.h"

@interface SuiteImageTableViewCell : Room107TableViewCell

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
- (void)setScrollViewImage:(NSArray *)arr;
//图片名称
- (void)setImageNames:(NSArray *)imageNames;
- (void)setAvatarImageViewWithURL:(NSString *)url;

@end
