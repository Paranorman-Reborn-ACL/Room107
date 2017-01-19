//
//  MessageListItemModel.h
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface MessageListItemModel : ManagedObject

@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, copy) NSString * timestamp;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, retain) NSNumber * hasNewUpdate;

@end
