//
//  IdentityInfoTableViewCell.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"
@class CustomTextField;
static CGFloat identityInfoTableViewCellHeight = 140.0f;

@interface IdentityInfoTableViewCell : Room107TableViewCell

@property (nonatomic, strong) CustomTextField *fullNameTextField;
@property (nonatomic, strong) CustomTextField *IDNumberTextField;
- (void)setName:(NSString *)name;
- (void)setIDCard:(NSString *)idCard;
- (NSString *)name;
- (NSString *)idCard;

@end
