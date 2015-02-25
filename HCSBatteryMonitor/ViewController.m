//
//  ViewController.m
//  HCSBatteryMonitor
//
//  Created by Sahil Kapoor on 24/02/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "ViewController.h"
#import "HCSBatteryMonitor.h"

@interface ViewController () <HCSBatteryMonitorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *batteryStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelTypeLabel;
@property (nonatomic, strong) HCSBatteryMonitor *batteryMonitor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    self.batteryMonitor.delegate = self;
    [self.batteryMonitor startMonitoring];
    [self.batteryMonitor notifyForBatteryLevels:@[@20, @30, @40]];
    self.batteryLevelTypeLabel.text = [self textForBatteryLevel:[self.batteryMonitor batteryLevel]];
    self.batteryStateLabel.text = [self textForState:[self.batteryMonitor batteryState]];
    self.batteryLevelLabel.text = [NSString stringWithFormat:@"%ld",[self.batteryMonitor currentBatteryPercentage]];
}

#pragma mark - HCSBatteryMonitorDelegate

- (void)batteryLevelReached:(NSInteger)percentage {
    self.batteryLevelLabel.text = [NSString stringWithFormat:@"%ld", (long)percentage];
}

- (void)significantBatteryLevelChange:(HCSBatteryLevel)level {
    self.batteryLevelTypeLabel.text = [self textForBatteryLevel:level];
}

- (void)currentBatteryStateChanged:(UIDeviceBatteryState)state {
    self.batteryStateLabel.text = [self textForState:state];
}

- (void)currentBatteryLevelChanged:(NSInteger)percentage {
    self.batteryLevelLabel.text = [NSString stringWithFormat:@"%ld", (long)percentage];
}

- (void)currentBatteryLevelChanged:(NSInteger)percentage state:(UIDeviceBatteryState)state {
    self.batteryStateLabel.text = [self textForState:state];
    self.batteryLevelLabel.text = [NSString stringWithFormat:@"%ld", (long)percentage];
}

#pragma mark - Helpers

- (NSString *)textForState:(UIDeviceBatteryState)state {
    NSLog(@"%ld", state);
    switch (state) {
        case UIDeviceBatteryStateUnplugged:return @"Unplugged";
        case UIDeviceBatteryStateCharging:return @"Charging";
        case UIDeviceBatteryStateFull:return @"Full";
        default:return @"Unknown";
    }
}

- (NSString *)textForBatteryLevel:(HCSBatteryLevel)level {
    switch (level) {
        case HCSBatteryLevelCriticallyLow:return @"CriticallyLow";
        case HCSBatteryLevelLow:return @"Low";
        case HCSBatteryLevelNormal:return @"Normal";
        case HCSBatteryLevelFull:return @"Full";
        default:return @"Unknown";
    }
}

#pragma mark - Actions

- (IBAction)reportOnChargingSwitch:(UISwitch *)sender {
    self.batteryMonitor.reportLevelOnCharging = sender.isOn;
}

#pragma mark - Lazy Initializer

- (HCSBatteryMonitor *)batteryMonitor {
    if (!_batteryMonitor) {
        _batteryMonitor = [HCSBatteryMonitor sharedManager];
    }
    
    return _batteryMonitor;
}

@end
