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

/**
 *  HCSBatteryLevel
 */
typedef NS_ENUM(NSInteger, HCSBatteryLevel){
    /**
     *  When battery level cannot be determined.
     */
    HCSBatteryLevelUnknown = 0,
    /**
     *  Less than 10% battery level.
     */
    HCSBatteryLevelCriticallyLow,
    /**
     *  Battery level between 10% to 19%.
     */
    HCSBatteryLevelLow,
    /**
     *  Battery level between 20% to 99%.
     */
    HCSBatteryLevelNormal,
    /**
     *  100% Battery Level
     */
    HCSBatteryLevelFull
};

@interface HCSBatteryMonitor : NSObject

/**
 *  Delegate method to run your methods whenever battery level/state changes.
 */
@property (nonatomic, strong) id<HCSBatteryMonitorDelegate> delegate;

/**
 *  Default is NO. When set NO, delegate methods for change in battery level(percentage) are not when device is charging.
 */
@property (nonatomic) BOOL reportLevelOnCharging;

/**
 *  HCSBatteryMonitor Singleton
 *
 *  @return Initialized HCSBatteryMonitor object
 */
+ (instancetype)sharedManager;

/**
 *  Start Battery Monitoring. Required to be called for using delegate methods.
 */
- (void)startMonitoring;

/**
 *  Stop Battery Monitoring. No delegate methods called after this method is called.
 */
- (void)stopMonitoring;

/**
 *  Provide a single battery percentage to be notified at.
 *
 *  @param percentage Percentage between 1 to 100.
 */
- (void)notifyForBatteryLevel:(NSInteger)percentage;

/**
 *  Provide list of battery percentages to be notified at.
 *
 *  @param percentages NSArray containing NSNumbers with integer values(between 1 to 100).
 */
- (void)notifyForBatteryLevels:(NSArray *)percentages;

/**
 *  Returns if device is charging.
 *
 *  @return YES if charging, NO otherwise.
 */
- (BOOL)isPlugged;

/**
 *  Returns if device is Fully Charged.
 *
 *  @return YES if battery level is 100, NO otherwise.
 */
- (BOOL)isFullyCharged;

/**
 *  Returns current HCSBatteryLevel based on current charge.
 *
 *  @return HCSBatteryLevel: Unknown, CricticallyLow, Low, Normal, Full.
 */
- (HCSBatteryLevel)batteryLevel;

/**
 *  Returns current battery level in percentage.
 *
 *  @return Integer between 1 to 100.
 */
- (NSInteger)currentBatteryPercentage;

/**
 *  Returns device charging state in native form.
 *
 *  @return UIDeviceBatteryState: Unknown, Unplugged, Charging, Full.
 */
- (UIDeviceBatteryState)batteryState;

@end

@protocol HCSBatteryMonitorDelegate <NSObject>

@optional

/**
 *  Called if battery value reaches the percentages set in notifyForBatteryLevel and notifyForBatteryLevels.
 *
 *  @param percentage   Value between 1 - 100.
 */
- (void)batteryLevelReached:(NSInteger)percentage;

/**
 *  Called in DISCHARGING state whenever battery reaches 10%(critically low), 20%(low) or 100%(fully charged).
 *
 *  @param level        HCSBatteryLevel: Unknown, CricticallyLow, Low, Normal, Full.
 */
- (void)significantBatteryLevelChange:(HCSBatteryLevel)level;

/**
 *  Called whenever battery state changes - Unplugged, Charging, Full.
 *
 *  @param state        UIDeviceBatteryState: Unknown, Unplugged, Charging, Full.
 */
- (void)currentBatteryStateChanged:(UIDeviceBatteryState)state;

/**
 *  Called whenever battery level changes.
 *
 *  @param percentage   Value between 1 - 100
 */
- (void)currentBatteryLevelChanged:(NSInteger)percentage;

/**
 *  Called whenever either battery level or battery state changes.
 *
 *  @param percentage   Value between 1 - 100
 *  @param state        UIDeviceBatteryState: Unknown, Unplugged, Charging, Full.
 */
- (void)currentBatteryLevelChanged:(NSInteger)percentage state:(UIDeviceBatteryState)state;

@end
