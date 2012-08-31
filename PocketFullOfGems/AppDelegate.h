//
//  AppDelegate.h
//  PocketFullOfGems
//
//  Created by Ashik Manandhar on 3/5/12.
//  Copyright Pocket Gems 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
