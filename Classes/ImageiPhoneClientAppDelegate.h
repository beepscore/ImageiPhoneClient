//
//  iPhoneClientAppDelegate.h
//  iPhoneClient
//	HW7
//
//  portions Copyright 2010 Chris Parrish

#import <UIKit/UIKit.h>

@interface ImageiPhoneClientAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

