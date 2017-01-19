//
//  SuiteProfileView.h
//  room107
//
//  Created by ningxia on 16/1/26.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuiteProfileView : UIView

- (void)setRoomImageURL:(NSString *)url;
- (void)setAvatarImageURL:(NSString *)url;
- (void)setReadStatus:(BOOL)isRead;
- (void)setPosition:(NSString *)position;
- (void)setRoomType:(NSString *)roomType;
- (void)setIntentionInfo:(NSString *)intention;
- (void)setDistance:(NSNumber *)distance;
- (void)setDateString:(NSString *)dateString;
- (void)setFeatureTagIDs:(NSArray *)tagIDs;
- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler;
- (void)setPrice:(NSNumber *)price;

@end
