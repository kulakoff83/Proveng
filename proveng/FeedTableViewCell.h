//
//  FeedTableViewCell.h
//  proveng
//
//  Created by Dmitry Kulakov on 27.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

@import UIKit;
#import "BaseTableViewCell.h"

@class Event;

@interface FeedTableViewCell : BaseTableViewCell

@property (nonatomic,getter=isSelectable) BOOL selectable;
@property  (nonatomic, copy, nonnull) void(^buttonPressedHandler)(Event* _Nonnull event, BOOL accepted);

- (void)configureCellWithEvent:(Event* _Nonnull)event;
- (void)setDeniedState;
- (void)setAcceptState;
- (void)hideButtons;
- (IBAction)denyButtonPressed:(id _Nullable)sender;
- (IBAction)acceptButtonPressed:(id _Nullable)sender;

@end
