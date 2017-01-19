//
//  BottomSurroundingCollectionViewCell.h
//  room107
//
//  Created by 107间 on 16/2/17.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomSurroundingCollectionViewCell : UICollectionViewCell

- (void)setCellSelected;
- (void)setCellDeSelected;
- (void)setIcon:(NSString *)icon text:(NSString *)text;

@end
