//
//  MapPositionViewController.h
//  room107
//
//  Created by ningxia on 15/7/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

@interface MapPositionViewController : Room107ViewController

- (void)setCoordinate:(CLLocationCoordinate2D)coor position:(NSString *)pos;

@end
