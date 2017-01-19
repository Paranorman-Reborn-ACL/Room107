//
//  SignedInviteTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

static CGFloat signedInviteTableViewCellHeight = 70.0f;

@interface SignedInviteTableViewCell : Room107TableViewCell

- (void)setAvatarImageURL:(NSString *)url;
- (void)setRequestStatus:(NSNumber *)status;
- (void)setWaitOtherContract:(BOOL)wait;
- (void)setTenantName:(NSString *)name;
- (void)setTelephone:(NSString *)telephone;
- (void)setCheckinTime:(NSString *)time;
- (void)setExitTime:(NSString *)time;
- (void)setNewUpdate:(NSNumber *)newUpdate;
- (void)setLongPressHandler:(void(^)(SignedInviteTableViewCell *signedInviteTableViewCell))handler;

@end
