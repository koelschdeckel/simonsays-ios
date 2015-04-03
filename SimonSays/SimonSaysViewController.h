//
//  ViewController.h
//  SimonSays
//
//  Created by Matthias Krauß on 27.01.15.
//  Copyright (c) 2015 Matthias Krauß. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimonSaysViewController : UIViewController

@property (readonly, strong) NSString* status;

- (IBAction) newGame:(id)sender;
- (IBAction) repeat:(id)sender;
- (IBAction) playButton1:(id)sender;
- (IBAction) playButton2:(id)sender;
- (IBAction) playButton3:(id)sender;
- (IBAction) playButton4:(id)sender;
- (IBAction) playButton5:(id)sender;
- (IBAction) playButton6:(id)sender;

@end

