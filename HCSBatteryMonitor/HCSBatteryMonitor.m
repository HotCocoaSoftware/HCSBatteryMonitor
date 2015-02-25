//
//  HCSBatteryMonitor.m
//  HCSBatteryMonitor
//
//  Created by Sahil Kapoor on 24/02/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "HCSBatteryMonitor.h"

static CGFloat const kBatteryCriticallyLowLevel = 10.f;
static CGFloat const kBatteryLowLevel = 20.f;

@interface HCSBatteryMonitor ()

@property (nonatomic, strong) NSSet *percentages;
@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) HCSBatteryLevel batteryLevel;

@end

@implementation HCSBatteryMonitor

+ (instancetype)sharedManager {
    static HCSBatteryMonitor *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HCSBatteryMonitor alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _reportLevelOnCharging = NO;
        _batteryLevel = HCSBatteryLevelUnknown;
        _percentages = nil;
    }
    
    return self;
}

- (void)startMonitoring {
    UIDevice *device = [UIDevice currentDevice];
    [self activateBatteryMonitoring:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelChanged:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:device];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateChanged:)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:device];
}

- (void)stopMonitoring {
    [self activateBatteryMonitoring:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handlers

- (void)batteryLevelChanged:(NSNotification *)notification {
    UIDevice *device = notification.object;
    NSInteger batteryPercentage =  (NSInteger)(device.batteryLevel * 100);
    HCSBatteryLevel level = [self currentBatteryLevelForPercentage:batteryPercentage];
    
    if (_reportLevelOnCharging == NO) {
        if (device.batteryState != UIDeviceBatteryStateUnknown) {
            return;
        }
    }
    
    if (device.batteryState != UIDeviceBatteryStateCharging) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(significantBatteryLevelChange:)]) {
            if (level != self.batteryLevel) {
                [self.delegate significantBatteryLevelChange:level];
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(batteryLevelReached:)]) {
        [self.percentages enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            NSNumber *value = obj;
            if ([value integerValue] == (NSInteger)(batteryPercentage * 100)) {
                [self.delegate batteryLevelReached:batteryPercentage];
            }
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentBatteryLevelChanged:)]) {
        [self.delegate currentBatteryLevelChanged:batteryPercentage];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentBatteryLevelChanged:state:)]) {
        [self.delegate currentBatteryLevelChanged:batteryPercentage state:device.batteryState];
    }
    
    self.batteryLevel = level;
}

- (void)batteryStateChanged:(NSNotification *)notification {
    
    UIDevice *device = notification.object;
    NSInteger batteryPercentage =  (NSInteger)(device.batteryLevel * 100);
    UIDeviceBatteryState currentState = device.batteryState;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentBatteryStateChanged:)]) {
        [self.delegate currentBatteryStateChanged:currentState];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(currentBatteryLevelChanged:state:)]) {
        [self.delegate currentBatteryLevelChanged:batteryPercentage state:currentState];
    }
    
    self.batteryLevel = [self currentBatteryLevelForPercentage:batteryPercentage];
}

#pragma mark - Additional Functionalities

- (BOOL)isPlugged {
    UIDevice *device = [UIDevice currentDevice];
    if (self.isMonitoring) {
        return (device.batteryState != UIDeviceBatteryStateUnplugged);
    } else {
        [self activateBatteryMonitoring:YES];
        BOOL isPluuged = (device.batteryState != UIDeviceBatteryStateUnplugged);
        [self activateBatteryMonitoring:NO];
        return isPluuged;
    }
}

- (BOOL)isFullyCharged {
    UIDevice *device = [UIDevice currentDevice];
    if (self.isMonitoring) {
        return (device.batteryState == UIDeviceBatteryStateFull);
    } else {
        [self activateBatteryMonitoring:YES];
        BOOL isFull =  device.batteryState == UIDeviceBatteryStateFull;
        [self activateBatteryMonitoring:NO];
        return isFull;
    }
}

- (HCSBatteryLevel)batteryLevel {
    UIDevice *device = [UIDevice currentDevice];
    if (self.isMonitoring) {
        return [self currentBatteryLevelForPercentage:(NSInteger)(device.batteryLevel * 100)];
    } else {
        [self activateBatteryMonitoring:YES];
        HCSBatteryLevel batteryLevel = [self currentBatteryLevelForPercentage:(NSInteger)(device.batteryLevel * 100)];
        [self activateBatteryMonitoring:NO];
        return batteryLevel;
    }
}

- (NSInteger)currentBatteryPercentage {
    UIDevice *device = [UIDevice currentDevice];
    if (self.isMonitoring) {
        return (NSInteger)(device.batteryLevel * 100);
    } else {
        [self activateBatteryMonitoring:YES];
        NSInteger percentage = (NSInteger)(device.batteryLevel * 100);
        [self activateBatteryMonitoring:NO];
        return percentage;
    }
}

- (UIDeviceBatteryState)batteryState {
    UIDevice *device = [UIDevice currentDevice];
    if (self.isMonitoring) {
        return device.batteryState;
    } else {
        [self activateBatteryMonitoring:YES];
        NSInteger batteryLevel = device.batteryState;
        [self activateBatteryMonitoring:NO];
        return batteryLevel;
    }
}

#pragma mark - Helper

- (void)activateBatteryMonitoring:(BOOL)enabled {
    [UIDevice currentDevice].batteryMonitoringEnabled = enabled;
    self.isMonitoring = enabled;
}

- (HCSBatteryLevel)currentBatteryLevelForPercentage:(NSInteger)batteryPercentage {
    if (batteryPercentage < kBatteryCriticallyLowLevel) {
        return HCSBatteryLevelCriticallyLow;
    } else if (batteryPercentage < kBatteryLowLevel) {
        return HCSBatteryLevelLow;
    } else if (batteryPercentage < 100) {
        return HCSBatteryLevelNormal;
    } else if (batteryPercentage ==  100) {
        return HCSBatteryLevelFull;
    } else {
        return HCSBatteryLevelUnknown;
    }
}

- (void)notifyForBatteryLevel:(NSInteger)percentage {
    _percentages = [NSSet setWithObject:[NSNumber numberWithInteger:percentage]];
}

- (void)notifyForBatteryLevels:(NSArray *)percentages {
    _percentages = [NSSet setWithArray:percentages];
}

@end
