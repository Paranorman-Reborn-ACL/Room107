//
//  UncaughtExceptionHandler.h
//  room107
//
//  Created by 107间 on 16/2/26.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject
{
    BOOL dismissed;
}
@end

void InstallUncaughtExceptionHandler();