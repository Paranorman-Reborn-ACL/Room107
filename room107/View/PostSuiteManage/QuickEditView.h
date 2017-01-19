//
//  QuickEditView.h
//  room107
//
//  Created by ningxia on 16/4/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickEditView : UIView

- (id)initWithFrame:(CGRect)frame withButtonTitle:(NSString *)title;
- (void)setButtonDidClickHandler:(void(^)())handler;

@end
