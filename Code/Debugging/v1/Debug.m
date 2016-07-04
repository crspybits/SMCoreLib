//
//  Debug.m
//  Petunia
//
//  Created by Christopher Prince on 11/9/13.
//  Copyright (c) 2013 Spastic Muffin, LLC. All rights reserved.
//

#import "Debug.h"
#import "PlayPetAudio.h"

@implementation Debug

+ (void) assertTrue: (BOOL) mustBeTrue withMessage: (NSString *) message {
    if (! mustBeTrue) {
        SPASLogFile(@"%@", message);
#ifdef AllDebug
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Assertion Error" message:message delegate:nil cancelButtonTitle:@"Error" otherButtonTitles:nil];
        [PlayPetAudio showErrorAlertAndPlayForAnimalType:alert animalType:nil];
#endif
    }
}

@end
