//
//  AuditStatusForPostViewController.h
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

@interface AuditStatusForPostViewController : Room107ViewController

- (void)setHouseJSON:(NSMutableDictionary *)houseJSON;
- (void)setDoneButtonDidClickHandler:(void(^)())handler;

@end
