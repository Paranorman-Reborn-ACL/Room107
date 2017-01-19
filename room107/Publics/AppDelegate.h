//
//  AppDelegate.h
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext; //管理对象，上下文，持久性存储模型对象
@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel; //被管理的数据模型，数据结构
@property (readonly, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator; //连接数据库的

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

- (void)InitializeTencentOAuth;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)clearPersistentStore;
// 判断设备是否有摄像头
- (BOOL)isCameraAvailable;
// 检查摄像头是否支持拍照
- (BOOL)doesCameraSupportTakingPhotos;
// 判断是否支持某种多媒体类型：拍照，视频
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;

@end

