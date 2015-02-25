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

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) HCSBatteryMonitor *batteryMonitor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self logToScreen:@"Started Monitorng"];
    self.batteryMonitor.delegate = self;
    [self.batteryMonitor startMonitoring];
    [self.batteryMonitor notifyForBatteryLevels:@[@20, @30, @40]];
}

#pragma mark - HCSBatteryMonitorDelegate

- (void)batteryLevelReached:(NSInteger)percentage {
    NSString *message = [NSString stringWithFormat:@"batteryLevelReached:%ld", (long)percentage];
    [self logToScreen:message];
}

- (void)significantBatteryLevelChange:(HCSBatteryLevel)level {
    NSString *message = @"significantBatteryLevelChange:";
    
    switch (level) {
        case HCSBatteryLevelCriticallyLow:message = [message stringByAppendingString:@"CriticallyLow"];
            break;
        case HCSBatteryLevelLow:message = [message stringByAppendingString:@"Low"];
            break;
        case HCSBatteryLevelNormal:message = [message stringByAppendingString:@"Normal"];
            break;
        case HCSBatteryLevelFull:message = [message stringByAppendingString:@"Full"];
            break;
        default: message = [message stringByAppendingString:@"Unknown"];
            break;
    }
    
    [self logToScreen:message];
}

- (void)currentBatteryStateChanged:(UIDeviceBatteryState)state {
    NSString *message = @"currentBatteryStateChanged:";

    switch (state) {
        case UIDeviceBatteryStateUnplugged:message = [message stringByAppendingString:@"Unplugged"];
            break;
        case UIDeviceBatteryStateCharging:message = [message stringByAppendingString:@"Charging"];
            break;
        case UIDeviceBatteryStateFull:message = [message stringByAppendingString:@"Full"];
            break;
        default: message = [message stringByAppendingString:@"Unknown"];
            break;
    }
    
    [self logToScreen:message];
}

- (void)currentBatteryLevelChanged:(NSInteger)batteryLevel {
    NSString *message = [NSString stringWithFormat:@"currentBatteryLevelChanged:%ld", (long)batteryLevel];
    [self logToScreen:message];
}

- (void)currentBatteryLevelChanged:(NSInteger)batteryLevel state:(UIDeviceBatteryState)state {
    NSString *message = [NSString stringWithFormat:@"currentBatteryLevelChanged:%ld state:", (long)batteryLevel];
    switch (state) {
        case UIDeviceBatteryStateUnplugged:message = [message stringByAppendingString:@"Unplugged"];
            break;
        case UIDeviceBatteryStateCharging:message = [message stringByAppendingString:@"Charging"];
            break;
        case UIDeviceBatteryStateFull:message = [message stringByAppendingString:@"Full"];
            break;
        default: message = [message stringByAppendingString:@"Unknown"];
            break;
    }

    [self logToScreen:message];
}

#pragma mark - Helper

- (void)logToScreen:(NSString *)message {
    self.textView.text = [NSString stringWithFormat:@"%@\n----------\n%@", self.textView.text, message];
}

#pragma mark - Lazy Initializer

- (HCSBatteryMonitor *)batteryMonitor {
    if (!_batteryMonitor) {
        _batteryMonitor = [HCSBatteryMonitor sharedManager];
    }
    
    return _batteryMonitor;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_textView];
    }
    
    return _textView;
}

@end
