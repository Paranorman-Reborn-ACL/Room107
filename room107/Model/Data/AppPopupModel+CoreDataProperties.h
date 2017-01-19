//
//  AppPopupModel+CoreDataProperties.h
//  room107
//
//  Created by ningxia on 15/10/12.
//  Copyright © 2015年 107room. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AppPopupModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppPopupModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *activatedUri;
@property (nullable, nonatomic, retain) NSNumber *frequency;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *popupDescription;
@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *targetUri;
@property (nullable, nonatomic, retain) id targetParams;

@end

NS_ASSUME_NONNULL_END
