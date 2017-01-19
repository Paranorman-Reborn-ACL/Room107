//
//  MapFullAddressTableViewCell.h
//  room107
//
//  Created by 107间 on 16/4/26.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107TableViewCell.h"

@interface MapFullAddressTableViewCell : Room107TableViewCell

- (NSString *)position;
- (void)setPosition:(NSString *)position;
- (void)setCountOfSubscriber:(NSString *)count;
- (void)setAddressDidBeginEditingHandler:(void(^)())handler;
- (void)setTextFieldDidEndEditingHandler:(void(^)(NSString *text))handler;
- (void)setImageURLwithMarkers:(NSArray *)markers andLocationX:(NSNumber *)locationX andLocationY:(NSNumber *)locationY;
+ (CGFloat)getmapFullAddressTableViewCellHeight;

@end
