//
//  RightMenuViewItem.h
//  room107
//
//  Created by 107间 on 16/3/10.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RightMenuViewItem;

@protocol RightMenuViewItemDelegate <NSObject>

@optional
- (void)rightMenudidSelectedItem:(RightMenuViewItem *)rightMenuViewItem;

@end

@interface RightMenuViewItem : UIView

@property (nonatomic, weak) id<RightMenuViewItemDelegate> delegate;
- (instancetype)initWithSize:(CGSize)size title:(NSString *)title clickComplete:(void(^)())complete;
- (instancetype)initWithTitle:(NSString *)title clickComplete:(void(^)())complete;

@end
