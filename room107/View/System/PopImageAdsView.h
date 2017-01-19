//
//  PopImageAdsView.h
//  room107
//
//  Created by ningxia on 16/3/9.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopImageAdsView : UIView

- (instancetype)initWithAdsImageURL:(NSString *)imageURL andHtmlURL:(NSString *)htmlURL;
- (void)setAdsImageDidClickHandler:(void(^)(NSString *htmlURL))handler;

@end
