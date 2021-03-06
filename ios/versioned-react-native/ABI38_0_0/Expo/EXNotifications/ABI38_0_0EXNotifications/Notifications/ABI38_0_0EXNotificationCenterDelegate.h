// Copyright 2018-present 650 Industries. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ABI38_0_0UMCore/ABI38_0_0UMSingletonModule.h>
#import <UserNotifications/UserNotifications.h>
#import <ABI38_0_0EXNotifications/ABI38_0_0EXNotificationsDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ABI38_0_0EXNotificationCenterDelegate

- (void)addDelegate:(id<ABI38_0_0EXNotificationsDelegate>)delegate;
- (void)removeDelegate:(id<ABI38_0_0EXNotificationsDelegate>)delegate;

@end

@interface ABI38_0_0EXNotificationCenterDelegate : ABI38_0_0UMSingletonModule <UIApplicationDelegate, UNUserNotificationCenterDelegate, ABI38_0_0EXNotificationCenterDelegate>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification;

@end

NS_ASSUME_NONNULL_END
