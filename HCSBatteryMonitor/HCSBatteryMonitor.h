//
//  HCSBatteryMonitor.h
//  HCSBatteryMonitor
//
//  Created by Sahil Kapoor on 24/02/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HCSBatteryMonitorDelegate;

typedef NS_ENUM(NSInteger, HCSBatteryLevel) {
    HCSBatteryLevelUnknown = 0,
    HCSBatteryLevelCriticallyLow,   // Less than 10%
    HCSBatteryLevelLow,             // Less than 20%
    HCSBatteryLevelNormal,          // Less than 20-99%%
    HCSBatteryLevelFull             // Fully Charged
};

@interface HCSBatteryMonitor : NSObject

@property (nonatomic, strong) id<HCSBatteryMonitorDelegate> delegate;
@property (nonatomic) BOOL reportOnlyOnDischarging;           //Default value is YES

+ (instancetype)sharedManager;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)notifyForBatteryLevel:(NSInteger)percentage;
- (void)notifyForBatteryLevels:(NSArray *)percentages;

- (BOOL)isPlugged;
- (BOOL)isFullyCharged;
- (HCSBatteryLevel)batteryLevel;
- (NSInteger)currentBatteryPercentage;   // 1% - 100%
- (UIDeviceBatteryState)batteryState;

@end

@protocol HCSBatteryMonitorDelegate <NSObject>

@optional

- (void)batteryLevelReached:(NSInteger)percentage;
- (void)significantBatteryLevelChange:(HCSBatteryLevel)level;
- (void)currentBatteryStateChanged:(UIDeviceBatteryState)state;
- (void)currentBatteryLevelChanged:(NSInteger)batteryLevel;
- (void)currentBatteryLevelChanged:(NSInteger)batteryLevel state:(UIDeviceBatteryState)state;

@end
