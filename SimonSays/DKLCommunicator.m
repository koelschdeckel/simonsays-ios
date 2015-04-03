//
//  DKLCommunicator.m
//
//  Created by Matthias Krauß on 12.10.14.
//  Copyright (c) 2014 Matthias Krauß. All rights reserved.
//

#import "DKLCommunicator.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define DKL_SERVICE_UUID   @"D5AFCDD4-F105-48FE-BA26-65554C61BC00"
#define DKL_COMM_CHAR_UUID  @"D5AF2001-F105-48FE-BA26-65554C61BC00"

@interface DKLCommunicator () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (readwrite, assign) DKLCommunicatorState state;

@property (strong) CBCentralManager* manager;
@property (strong) CBPeripheral* dkl;
@property (strong) CBService* dklService;
@property (strong) CBCharacteristic* commCharacteristic;

@end

@implementation DKLCommunicator

- (id) init {
    self = [super init];
    if (!self) return nil;
    self.state = State_Initializing;
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    return self;
}

- (BOOL) rescan {
    if (self.state == State_BTOff) return NO;
    if (self.state == State_BTDisallowed) return NO;
    if (self.state == State_BTUnavailable) return NO;
    [self.manager stopScan];
    self.dkl = nil;        //assume none found - will also disconnect if we're still connected
    self.dklService = nil;
    self.commCharacteristic = nil;
    NSArray* services = @[[CBUUID UUIDWithString:DKL_SERVICE_UUID]];
    self.state = State_Scanning;
    [self.manager scanForPeripheralsWithServices:services options:@{}];
    return YES;
}

- (BOOL) sendCommand:(NSData*)data {
    NSLog(@"sending command %@",data);
    if (self.state != State_Connected) {
        return NO;
    }
    [self.dkl writeValue:data forCharacteristic:self.commCharacteristic type:CBCharacteristicWriteWithResponse];
    return YES;
}

//CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateUnsupported:
            self.state = State_BTUnavailable;
            break;
        case CBCentralManagerStateUnauthorized:
            self.state = State_BTDisallowed;
            break;
        case CBCentralManagerStatePoweredOff:
            self.state = State_BTOff;
            break;
        case CBCentralManagerStatePoweredOn:
            [self rescan];
            break;
        default:
            //transient states
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    self.dkl = peripheral;
    self.dkl.delegate = self;
    [self.manager stopScan];
    self.state = State_Connecting;
    [self.manager connectPeripheral:peripheral options:@{}];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    NSLog(@"did connect");
    NSArray* uuids = @[[CBUUID UUIDWithString:DKL_SERVICE_UUID]];
    [peripheral discoverServices:uuids];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"failed to connect: %@",error);
    [self rescan];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnected: %@",error);
    [self rescan];
}

//CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    NSLog(@"discovered services");
    if (error) {
        [self rescan];
        return;
    }
    NSArray* services = [self.dkl services];
    if (services.count < 1) {
        [self rescan];
        return;
    }
    self.dklService = services[0];
    
    NSUUID* commUUID = [[NSUUID alloc] initWithUUIDString:DKL_COMM_CHAR_UUID];
    NSArray* uuids = @[commUUID];
    [self.dkl discoverCharacteristics:uuids forService:self.dklService];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    NSLog(@"discovered characteristics");
    if (error) {
        [self rescan];
        return;
    }
    NSArray* characteristics = [self.dklService characteristics];
    if (characteristics.count < 1) {
        [self rescan];
        return;
    }
    self.commCharacteristic = characteristics[0];
    self.state = State_Connected;
}


@end
