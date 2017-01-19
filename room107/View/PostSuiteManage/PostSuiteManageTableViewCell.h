//
//  PostSuiteManageTableViewCell.h
//  room107
//
//  Created by ningxia on 15/7/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107TableViewCell.h"

@protocol PostSuiteManageTableViewCellDelegate;

@interface PostSuiteManageTableViewCell : Room107TableViewCell

@property (nonatomic, weak) id<PostSuiteManageTableViewCellDelegate> delegate;

- (void)setItemDic:(NSDictionary *)itemDic;
- (void)setHouseStatus:(NSNumber *)status;
- (void)setButtonType:(NSNumber *)type;
- (void)setNewUpdate:(NSNumber *)newUpdate;
- (void)setRentStatusButton:(NSNumber *)type;

@end

@protocol PostSuiteManageTableViewCellDelegate <NSObject>

- (void)suiteManageButtonDidClick:(PostSuiteManageTableViewCell *)postSuiteManageTableViewCell;
- (void)openOrCloseHouseButtonDidClick:(PostSuiteManageTableViewCell *)postSuiteManageTableViewCell;
- (void)signedInviteButtonDidClick:(PostSuiteManageTableViewCell *)postSuiteManageTableViewCell;

@end
