//
//  CLPlacemark+Extras.m
//  WhatDidILike
//
//  Created by Christopher Prince on 8/23/15.
//  Copyright (c) 2015 Spastic Muffin, LLC. All rights reserved.
//

#import "CLPlacemark+Extras.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
@implementation CLPlacemark (Extras)

- (NSString *) addressDictionaryCity;
{
    return self.addressDictionary[(NSString *) CNPostalAddressCityKey];
}

- (NSString *) addressDictionaryState;
{
    return self.addressDictionary[(NSString *) CNPostalAddressStateKey];
}

@end
