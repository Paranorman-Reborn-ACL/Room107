//
//  LicenseAgreementView.h
//  room107
//
//  Created by ningxia on 16/2/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicenseAgreementView : UIView

- (id)initWithFrame:(CGRect)frame withContent:(NSString *)content;
- (void)setStatus:(BOOL)selected;
- (BOOL)status;

@end
