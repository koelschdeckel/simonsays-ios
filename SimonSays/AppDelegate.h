//
//  AppDelegate.h
//  SimonSays
//
//  Created by Matthias Krauß on 27.01.15.
//  Copyright (c) 2015 Matthias Krauß. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DKLCommunicator;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) DKLCommunicator* dklCommunicator;


@end

