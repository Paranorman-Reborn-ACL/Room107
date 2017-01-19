//
//  OnlineDiscountTableViewCell.h
//  room107
//
//  Created by 107间 on 15/12/2.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat onlineDiscountTableViewCellHeight = 300.0f;

@interface OnlineDiscountTableViewCell : Room107TableViewCell

@property (nonatomic, copy) void(^whatsOnlineContractClickComplete)(void);
@property (nonatomic, copy) NSString *offlinePrice;

-(NSNumber *)rate;
-(NSNumber *)onlinePrice;

- (void)setRate:(NSNumber *)sender;

- (void)setOfflinePrice:(NSString *)offlinePrice onlinePrice:(NSString *)onlinePrice;
@end
