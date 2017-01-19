//
//  ContactModel.h
//  room107
//
//  Created by ningxia on 15/6/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

/*
 enum GenderType {
 
 UNKNOWN, MALE, FEMALE, MALE_AND_FEMALE;
 
 }
*/

@interface UserModel : ManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * faviconUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * constellation;
@property (nonatomic, retain) NSString * school;
@property (nonatomic, retain) NSString * major;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * profession;
@property (nonatomic, retain) NSNumber * verifyStatus;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * userDescription;
@property (nonatomic, retain) NSString * token;

@end
