//
//  KHDAppDelegate.m
//  DemoKhipu
//
//  Created by Iván on 12/4/13.
//  Copyright (c) 2013 khipu. All rights reserved.
//

#import "KHDAppDelegate.h"
#import "KHDLandingViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation KHDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        UIStoryboard *storyBoard;

        CGSize result = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = [UIScreen mainScreen].scale;
        result = CGSizeMake(result.width * scale, result.height * scale);

        if(result.height == 1136){
            storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        }else{
            storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_35" bundle:nil];
        }
        UIViewController *initViewController = [storyBoard instantiateInitialViewController];
        [self.window setRootViewController:initViewController];
    }


    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if(remoteNotif)
    {
        NSLog(@"Handle RemoteNotification with dictionary: \n%@", [remoteNotif description]);
    }


    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Hemos sido invocados con: %@",url.scheme);
    if ([url.scheme isEqualToString:@"khipuinstalled"]) {
        // khipu no estaba instalada al momento de ser requerido. Al terminar su instalación revisa si existe alguna aplicación que haya registrado el esquema khipuinstalled
        
        // Recuperamos la URL del cobro que aún no se ha podido procesar
        NSURL *myURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"pendingURL"];
        if (!myURL) {
            // En caso que la url ya no exista, respondemos que nuestra aplicación no es la que va a responder a esta invocación
            return NO;
        }else{
            // dado que tenemos la URL del cobro pendiente, realizamos nuevamente la llamada, y esta vez será capturada por khipu
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pendingURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UIApplication sharedApplication] openURL:myURL];
        }
        return YES;
    }else if ([url.scheme isEqualToString:@"khipudemo"]) {
        // khipu nos ha invocado, con el resultado del cobro
        [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:NO];
        NSString *message = @"";

        if ([url.description containsString:@"failure"]){
            // falla al procesar el cobro
            message = @"El servicio de pago informó que no se ha realizado el pago. Por favor intenta más tarde";
            [[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else{
            // el cobro ha sido realizado.
            KHDLandingViewController *aKHDLandingViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"KHDLandingViewController"];
            [(UINavigationController *)self.window.rootViewController pushViewController:aKHDLandingViewController animated:NO];
        }
        return YES;
    }

    return NO;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.window.rootViewController.navigationController popViewControllerAnimated:YES];
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *deviceTokenString = [[[[devToken description]
                                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                    stringByReplacingOccurrencesOfString: @">" withString: @""]
                                   stringByReplacingOccurrencesOfString: @" " withString: @""];

    NSLog(@"deviceTokenString: %@", deviceTokenString);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err.localizedDescription);
}

-(void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received Remote Notification with dictionary: \n%@", [userInfo description]);


    NSString *soundName = [userInfo valueForKey:@"soundName"];

    if (soundName && soundName.length > 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        NSURL *pewPewURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:@"caf"]];

        SystemSoundID _pewPewSound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
        AudioServicesPlaySystemSound(_pewPewSound);
    }



    if([app applicationState] == UIApplicationStateInactive)
    {
        //If the application state was inactive, this means the user pressed an action button
        // from a notification.
        
        //Handle notification
    }
}

@end
