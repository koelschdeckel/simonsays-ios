//
//  DKLCommunicator.h
//
//  Created by Matthias Krauß on 12.10.14.
//  Copyright (c) 2014 Matthias Krauß. All rights reserved.
//

#import <Foundation/Foundation.h>

/** communication states */
typedef enum {
    State_Initializing = 1,
    State_BTOff,
    State_BTUnavailable,
    State_BTDisallowed,
    State_Scanning,
    State_Connecting,
    State_Connected
} DKLCommunicatorState;

/** This class is the communication interface to the ^^dkl hardware */
@interface DKLCommunicator : NSObject

/** reflects the current state of communication with the external hardware. */
@property (readonly, assign) DKLCommunicatorState state;

/** trigger a rescan of devices. Rescans typically don't have to be triggered manually, but
 it might be helpful if something went wrong
 @return YES if the scan procedure was successfully (re-)started. */
- (BOOL) rescan;

/** sends a command.
 @param data data to send */
- (BOOL) sendCommand:(NSData*)data;

@end
