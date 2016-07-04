//
//  SMCoreLib.h
//  SMCoreLib
//
//  Created by Christopher Prince on 1/18/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

// To enable the DEBUG conditional compilation flag in Swift I found that the solution was to add -DDEBUG to OTHER_SWIFT_FLAGS in settings. See also http://marginalfutility.net/2015/10/11/swift-compiler-flags/ This flag is only enabled for debug builds, not release builds.

#import <UIKit/UIKit.h>

//! Project version number for SMCoreLib.
FOUNDATION_EXPORT double SMCoreLibVersionNumber;

//! Project version string for SMCoreLib.
FOUNDATION_EXPORT const unsigned char SMCoreLibVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SMCoreLib/PublicHeader.h>

#import <SMCoreLib/NSObject+TargetsAndSelectors.h>
#import <SMCoreLib/NSObject+Extras.h>
#import <SMCoreLib/TimedCallback.h>
#import <SMCoreLib/Network.h>
#import <SMCoreLib/UUID.h>
#import <SMCoreLib/RepeatingTimer.h>
#import <SMCoreLib/CoreData.h>
#import <SMCoreLib/CoreDataSource.h>
#import <SMCoreLib/SMMutableDictionary.h>
#import <SMCoreLib/LogFile.h>
#import <SMCoreLib/FileStorage.h>
#import <SMCoreLib/KeyChain.h>
#import <SMCoreLib/SMAssert.h>
#import <SMCoreLib/SMIdentifiers2.h>
#import <SMCoreLib/SMUIMessages.h>
#import <SMCoreLib/UIView+Extras.h>
#import <SMCoreLib/UserMessage.h>
#import <SMCoreLib/BiRef.h>
#import <SMCoreLib/WeakRef.h>
#import <SMCoreLib/Debounce.h>
#import <SMCoreLib/UIDevice+Extras.h>
#import <SMCoreLib/SMModal.h>
#import <SMCoreLib/ChangeFrameTransitioningDelegate.h>
#import <SMCoreLib/UIViewController+Extras.h>
#import <SMCoreLib/NSDate+Extras.h>
#import <SMCoreLib/SMEdgeInsetLabel.h>
#import <SMCoreLib/NSThread+Extras.h>
#import <SMCoreLib/UITableViewCell+Extras.h>
#import <SMCoreLib/UITableView+Extras.h>
#import <SMCoreLib/ImageStorage.h>
#import <SMCoreLib/SMAppearance.h>
#import <SMCoreLib/SMRotation.h>



