//
//  AppDelegate.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "AppDelegate.h"
#import "DDMenuController.h"
#import "MainViewController.h"
#import "LeftSiderViewController.h"


@implementation AppDelegate

- (void)initNavBarTitleStyle
{
    UIColor *textColor = [UIColor colorWithRed:245.0/255.0
                                         green:245.0/255.0
                                          blue:245.0/255.0 alpha:1.0];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 60000)
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        shadow.shadowOffset = CGSizeMake(0, 1);
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               textColor, NSForegroundColorAttributeName,
                                                               shadow, NSShadowAttributeName,
                                                               font, NSFontAttributeName, nil]];
#endif
    }
    else
    {
        UIColor *shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        NSValue *value =  [NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              textColor,UITextAttributeTextColor,
                              font,UITextAttributeFont,
                              shadowColor,UITextAttributeTextShadowColor,
                              value,UITextAttributeTextShadowOffset,nil];
        [[UINavigationBar appearance] setTitleTextAttributes:dict];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController *mainViewVC = [[MainViewController alloc]init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:mainViewVC];
    [self initNavBarTitleStyle];
    // 自定义导航栏标题
    NSString *imageName = iOS7 ? @"nav_bg_image_ios7" :@"nav_bg_image";
    UIImage *navBarImage = [UIImage imageNamed:imageName];
    [[UINavigationBar appearance]setBackgroundImage:navBarImage forBarMetrics: UIBarMetricsDefault];
    
    _menuController = [[DDMenuController alloc]initWithRootViewController:navController];
    
    LeftSiderViewController *leftSiderViewVC = [[LeftSiderViewController alloc]init];
    _menuController.leftViewController = leftSiderViewVC;
    
    self.window.rootViewController = _menuController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
