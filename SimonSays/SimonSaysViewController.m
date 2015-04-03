//
//  ViewController.m
//  SimonSays
//
//  Created by Matthias Krauß on 27.01.15.
//  Copyright (c) 2015 Matthias Krauß. All rights reserved.
//

#import "SimonSaysViewController.h"
#import "AppDelegate.h"
#import "DKLCommunicator.h"

typedef enum {
    USER_KEY_RED     = 1,
    USER_KEY_YELLOW  = 2,
    USER_KEY_GREEN   = 3,
    USER_KEY_CYAN    = 4,
    USER_KEY_BLUE    = 5,
    USER_KEY_PURPLE  = 6,
    USER_KEY_REPLAY  = 7,
    USER_KEY_NEWGAME = 8
} USER_KEY;

@interface SimonSaysViewController ()

@property (readwrite, strong) NSString* status;
@property (weak) DKLCommunicator* communicator;
@property (weak) IBOutlet UILabel* statusLabel;

@end

@implementation SimonSaysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.status = @"Starting";
    AppDelegate* ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.communicator = ad.dklCommunicator;
    [self.communicator addObserver:self forKeyPath:@"state" options:0 context:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"state"]) {
        switch (self.communicator.state) {
            case State_Initializing:
                self.status = @"Initializing";
                break;
            case State_BTOff:
                self.status = @"Bluetooth is off";
                break;
            case State_BTUnavailable:
                self.status = @"No Bluetooth available";
                break;
            case State_BTDisallowed:
                self.status = @"Bluetooth not permitted";
                break;
            case State_Scanning:
                self.status = @"Scanning for ^^dkl";
                break;
            case State_Connecting:
                self.status = @"Connecting to ^^dkl";
                break;
            case State_Connected:
                self.status = @"Connected";
                break;
        }
        self.statusLabel.text = self.status;
    }
}

- (void) sendUserKeyMessage:(USER_KEY)key {
    uint8_t buf[] = { 0x42, 0x02, 0x01, key };
    NSData* cmd = [NSData dataWithBytes:buf length:4];
    [self.communicator sendCommand:cmd];
}

- (IBAction) newGame:(id)sender {
    [self sendUserKeyMessage:USER_KEY_NEWGAME];
}

- (IBAction) repeat:(id)sender {
    [self sendUserKeyMessage:USER_KEY_REPLAY];
}

- (IBAction) playButton1:(id)sender {
    [self sendUserKeyMessage:USER_KEY_RED];
}

- (IBAction) playButton2:(id)sender {
    [self sendUserKeyMessage:USER_KEY_YELLOW];
}

- (IBAction) playButton3:(id)sender {
    [self sendUserKeyMessage:USER_KEY_GREEN];
}

- (IBAction) playButton4:(id)sender {
    [self sendUserKeyMessage:USER_KEY_CYAN];
}

- (IBAction) playButton5:(id)sender {
    [self sendUserKeyMessage:USER_KEY_BLUE];
}

- (IBAction) playButton6:(id)sender {
    [self sendUserKeyMessage:USER_KEY_PURPLE];
}


@end
