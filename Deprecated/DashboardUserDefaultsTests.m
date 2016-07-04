//
//  DashboardUserDefaultsTests.m
//  Petunia
//
//  Created by Christopher Prince on 12/11/14.
//  Copyright (c) 2014 Spastic Muffin, LLC. All rights reserved.
//

#import "DashboardUserDefaultsTests.h"
#import "PetDefs.h"
@import SMCoreLib;

#ifdef DEBUG
@interface DashboardUserDefaultsTests ()

@end

@implementation DashboardUserDefaultsTests

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SPASLog(@"getValueFor: %@", [PetDefs getValueFor:PETDEF_HOLDING_STATE_TRANSACTIONS]);
    
    NSSet *set = [NSSet setWithArray:@[@"abc", @"123"]];
    
    [PetDefs setValue:set for:PETDEF_HOLDING_STATE_TRANSACTIONS];
    SPASLog(@"getValueFor: %@", [PetDefs getValueFor:PETDEF_HOLDING_STATE_TRANSACTIONS]);
    
    [PetDefs setValue:nil for:PETDEF_HOLDING_STATE_TRANSACTIONS];
    SPASLog(@"getValueFor: %@", [PetDefs getValueFor:PETDEF_HOLDING_STATE_TRANSACTIONS]);
}

+ (NSString *) name;
{
    return @"User Defaults tests";
}

@end

#endif
