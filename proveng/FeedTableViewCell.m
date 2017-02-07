//
//  FeedTableViewCell.m
//  proveng
//
//  Created by Dmitry Kulakov on 27.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

#import "FeedTableViewCell.h"
#import "proveng-Swift.h"

static CGFloat ZeroConstant = 0;
static CGFloat TwoConstant = 2;
static CGFloat AcceptButtonHeightDefaultConstant = 25;
static CGFloat AcceptButtonTopDefaultConstant = 9;
static CGFloat AcceptButtonBottomDefaultConstant = 12;
static CGFloat AcceptButtonBottomMinConstant = 5;
static CGFloat InfoLabelLeftDefaultConstant = 5;
static CGFloat InfoImageViewWidthDefaultConstant = 12;
static CGFloat TitleIconWidthDefaultConstant = 30;
static CGFloat TitleLabelLeftDefaultConstant = 5;
static CGFloat InfoLabelHeightDefaultConstant = 15;
static CGFloat LocationImageViewWidthDefaultConstant = 12;
static CGFloat LocationImageViewRightDefaultConstant = 5;
static CGFloat DetailsLabelRightDefaultConstant = 84;

@interface FeedTableViewCell()

NS_ASSUME_NONNULL_BEGIN

@property (weak, nonatomic) IBOutlet UIImageView *pointsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (weak, nonatomic) IBOutlet UIView *eventTagView;
@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *titleIconImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *acceptButtonBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelLeftZero;//?
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationImageViewRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsLabelRight;

@property (nonatomic) Event *currentEvent;

NS_ASSUME_NONNULL_END

@end
@implementation FeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
    self.selectable = NO;
    self.statusLabel.hidden = YES;
    self.statusImageView.hidden = YES;
    self.contentView.backgroundColor =  UIColor.bgFromFeedCell;
    [self configureButtons];
    [self configureFonts];
    [self configureColors];
    [self setIcons];
    self.titleIconImageView.clipsToBounds = YES;
    self.titleIconImageView.layer.cornerRadius = TitleIconWidthDefaultConstant / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.alpha = 1.0;
    self.titleLabel.text = @" ";
    self.detailsLabel.text = @" ";
    self.infoLabel.text = @" ";
    self.detailsLabel.numberOfLines = 0;
    self.eventTagView.backgroundColor = [UIColor grayColor];
    self.infoLabelLeft.constant = InfoLabelLeftDefaultConstant;
    self.infoImageViewWidth.constant = InfoImageViewWidthDefaultConstant;
    self.titleIconWidth.constant = TitleIconWidthDefaultConstant;
    self.titleLabelLeft.constant = TitleLabelLeftDefaultConstant;
    self.infoLabelHeight.constant = InfoLabelHeightDefaultConstant;
    self.locationImageViewWidth.constant = LocationImageViewWidthDefaultConstant;
    self.locationImageViewRight.constant = LocationImageViewRightDefaultConstant;
    self.detailsLabelRight.constant = DetailsLabelRightDefaultConstant;
    self.infoLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.statusLabel.hidden = YES;
    self.dateLabel.textColor = [UIColor textFromFeedCell];
    self.statusImageView.hidden = YES;
    self.selectable = NO;
    self.indicatorImageView.image = nil;
    self.locationImageView.hidden = NO;
    self.titleLabel.textColor = [UIColor mainFromFeedCell];
    self.detailsLabel.textColor = [UIColor textFromFeedCell];
    [self showButtons];
    [self setIcons];
}

- (void)configureButtons {
    UIColor *acceptColor = [Event colorByTypeWithEventType:EventTypeAccepted];
    UIColor *denyColor = [Event colorByTypeWithEventType:EventTypeCancelled];
    self.acceptButton.layer.borderWidth = 1.0;
    self.acceptButton.layer.borderColor = acceptColor.CGColor;
    self.acceptButton.layer.cornerRadius = 5.0;
    [self.acceptButton setTitleColor:acceptColor forState:UIControlStateNormal];
    self.denyButton.layer.borderWidth = 1.0;
    self.denyButton.layer.borderColor = denyColor.CGColor;
    self.denyButton.layer.cornerRadius = 5.0;
    [self.denyButton setTitleColor:denyColor forState:UIControlStateNormal];
}

- (void)configureFonts {
    self.statusLabel.font = [UIFont fontWithName:@".SFUIDisplay-Light" size:12];
    self.dateLabel.font = [UIFont fontWithName:@".SFUIDisplay-Light" size:10];
    self.timeLabel.font = [UIFont fontWithName:@".SFUIDisplay-Light" size:11];
    self.detailsLabel.font = [UIFont fontWithName:@".SFUIText-Light" size:11];
    self.infoLabel.font = [UIFont fontWithName:@".SFUIText-Light" size:12];
    self.titleLabel.font = [UIFont fontWithName:@".SFUIText-Regular" size:17];
    self.eventTypeLabel.font = [UIFont fontWithName:@".SFUIDisplay-Light" size:10];
    self.acceptButton.titleLabel.font = [UIFont fontWithName:@".SFUIDisplay-Light" size:14];
    self.denyButton.titleLabel.font = [UIFont fontWithName:@".SFUIDisplay-Light" size:14];
}

- (void)configureColors {
    self.titleLabel.textColor = [UIColor mainFromFeedCell];
    self.dateLabel.textColor = [UIColor textFromFeedCell];
}

- (void)setIcons {
    self.locationImageView.image = [UIImage imageNamed:@"locationSmall"];
    self.pointsImageView.image = [UIImage imageNamed:@"pointsSmall"];
}

- (void)configureCellWithEvent:(FeedEvent*)event {
    self.currentEvent = event;
    self.indicatorImageView.image = [UIImage imageNamed:@"disclosure_indicator"];
    self.eventImageView.image = [Event iconByTypeWithEventType:event.typeEnum];
    self.eventTypeLabel.text = event.type;
    self.titleLabel.text = event.eventName;
    self.detailsLabel.text = event.location.place;
    NSString *startTime = [event.dateStart formattedDateStringWithFormat:@"HH:mm"];
    NSString *endTime = [event.dateEnd formattedDateStringWithFormat:@"HH:mm"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    self.infoLabelLeft.constant = TwoConstant;
    self.infoImageViewWidth.constant = ZeroConstant;
    
    switch (event.typeEnum) {
        case EventTypeWorkshop:
            [self configureFromWorkshop:event];
            break;
        case EventTypeLesson:
            [self configureFromLesson:event];
            break;
        case EventTypeMaterial:
            [self configureFromMaterial:event];
            break;
        case EventTypeTest:
            [self configureFromTest:event];
            break;
        case EventTypeUnknown:
            NSLog(@"EVENT UNKNOWN TYPE");
            [self configureFromUnknown:event];
            break;
        default:
            break;
    }
}

- (void)configureFromWorkshop:(FeedEvent*)event {
    self.selectable = YES;
    [self hideTitleIcon];
    self.infoLabel.text = @"Number Of Students 10";
    NSDate *date = [[NSDate date] makeLocalTime];
    if ([event.dateStart timeIntervalSinceDate: date] <= 3600 && [event.dateStart timeIntervalSinceDate: date] > 0 ){
        self.dateLabel.text = @"Starts in an hour";
        self.dateLabel.textColor = [UIColor additionalFromFeedCell];
        
    } else {
        self.dateLabel.text = [event.dateStart formattedDateStringWithFormat:@"MMM dd, YYYY"];
    }
    self.eventTagView.backgroundColor = [Event colorByTypeWithEventType:EventTypeWorkshop];
    self.indicatorImageView.image = [UIImage imageNamed:@"disclosure_indicator"];
    if ([event isPast]) {
        [self hideButtons];
    }
    [self checkTypeEventB:event];
}

- (void)configureFromLesson:(FeedEvent*)event {
    self.selectable = YES;
    [self hideTitleIcon];
    [self hideButtons];
    self.statusLabel.hidden = YES;
    self.eventTagView.backgroundColor = [Event colorByTypeWithEventType:EventTypeLesson];
    if (event.group.groupName != nil && event.group.groupLevel != nil) {
        self.infoLabel.text = [NSString stringWithFormat:@"%@(%@)",event.group.groupName, event.group.groupLevel.capitalizedString];
    } else {
        self.infoLabel.text = @"Group";
    }
    NSDate *date = [[NSDate date] makeLocalTime];
    if ([event.dateStart timeIntervalSinceDate: date] <= 3600 && [event.dateStart timeIntervalSinceDate: date] > 0 ){
        self.dateLabel.text = @"Starts in an hour";
        self.dateLabel.textColor = [UIColor additionalFromFeedCell];
    } else {
        self.dateLabel.textColor = [UIColor textFromFeedCell];
        self.dateLabel.text = [event.dateStart formattedDateStringWithFormat:@"MMM dd, YYYY"];
    }
}

- (void)configureFromTest:(FeedEvent*)event {
    self.selectable = YES;
    [self hideTitleIcon];
    [self hideButtons];
    self.statusLabel.hidden = YES;
    self.eventTagView.backgroundColor = [Event colorByTypeWithEventType:EventTypeTest];
    self.titleLabel.text = event.eventName;
    self.titleLabelLeft.constant = 1;
    self.infoLabelLeft.constant = InfoLabelLeftDefaultConstant;
    self.infoImageViewWidth.constant = InfoImageViewWidthDefaultConstant;
    CGFloat timeInt1 = [[NSDate date] timeIntervalSinceNow];
    CGFloat timeInt2 = [event.dateEnd timeIntervalSinceNow];
    CGFloat lifeTime = (timeInt2 - timeInt1) / 3600;
    NSString *lifeTitle = lifeTime > 1 ? @"hrs" : @"hr";
    if (lifeTime > 24) {
        lifeTime = (timeInt2 - timeInt1) / (3600 * 24);
        lifeTitle = @"d";
    }
    if (lifeTime > 30) {
        self.dateLabel.text = @"";
    } else {
        self.dateLabel.text = [NSString stringWithFormat:@"Ends of %.f %@",lifeTime,lifeTitle];
    }
    
    CGFloat minutes = [event.testItem.duration minutes];
    if (minutes > 0) {
        self.detailsLabel.text = [NSString stringWithFormat:@"Average time - %.f min",minutes];
    } else {
        self.detailsLabel.text = @"free time";
    }
    self.infoLabel.text = [NSString stringWithFormat:@"Points - %ld", event.testItem.weight];
    self.timeLabel.text = @"";
    self.locationImageView.image = [UIImage imageNamed:@"timeSmall"];
    [self checkTypeEventB:event];
}

- (void)configureFromMaterial:(FeedEvent*)event {
    self.selectable = YES;
    [self hideButtons];
    self.locationImageView.hidden = YES;
    self.infoLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.statusLabel.hidden = YES;
    
    self.detailsLabelRight.constant = TwoConstant;
    self.locationImageViewWidth.constant = ZeroConstant;
    self.locationImageViewRight.constant = ZeroConstant;
    self.infoLabelHeight.constant = ZeroConstant;
    
    self.titleLabel.textColor = [UIColor textFromFeedCell];
    self.detailsLabel.textColor = [UIColor mainFromFeedCell];
    self.detailsLabel.numberOfLines = 1;
    self.eventTagView.backgroundColor = [Event colorByTypeWithEventType:EventTypeMaterial];
    
    self.detailsLabel.text = event.materialItem.link;
    self.dateLabel.text = [NSString stringWithFormat:@"%@",[event.dateStart timeAgoShort]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ shared a material",event.leaderName];
    [self.titleIconImageView requestOriginalImage:[NSURL URLWithString:event.leaderImageURL]];
}

- (void)configureFromUnknown:(FeedEvent*)event {
    [self hideTitleIcon];
    self.selectable = NO;
    [self hideButtons];
    self.locationImageView.hidden = YES;
    self.infoLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.statusLabel.hidden = YES;
    self.indicatorImageView.hidden = YES;
    self.dateLabel.text = [NSString stringWithFormat:@"%@",[event.dateStart timeAgoShort]];
}

- (void)checkTypeEventB:(Event*)event {
    if ([event containsEventByType:EventTypeCancelled]) {
        [self setDeniedState];
    } else if ([event containsEventByType:EventTypeAccepted]) {
        [self setAcceptState];
    }
}

- (void)hideTitleIcon {
    self.titleIconWidth.constant = ZeroConstant;
    self.titleLabelLeft.constant = TwoConstant;
}

- (void)hideButtons {
    self.denyButton.hidden = YES;
    self.acceptButton.hidden = YES;
    self.acceptButtonHeight.constant = ZeroConstant;
    self.acceptButtonTop.constant = ZeroConstant;
    self.acceptButtonBottom.constant = AcceptButtonBottomMinConstant;
}

- (void)showButtons {
    self.denyButton.hidden = NO;
    self.acceptButton.hidden = NO;
    self.acceptButtonHeight.constant = AcceptButtonHeightDefaultConstant;
    self.acceptButtonTop.constant = AcceptButtonTopDefaultConstant;
    self.acceptButtonBottom.constant = AcceptButtonBottomDefaultConstant;
}

- (void)setDeniedState {
    self.statusLabel.hidden = NO;
    self.statusImageView.hidden = NO;
    [self hideButtons];
    self.statusLabel.textColor = [Event colorByTypeWithEventType:EventTypeCancelled];
    self.statusLabel.text = @"declined";
    self.statusImageView.image = [UIImage imageNamed:@"declined"];
}

- (void)setAcceptState {
    self.statusLabel.hidden = NO;
    self.statusImageView.hidden = NO;
    [self hideButtons];
    self.statusLabel.textColor = [Event colorByTypeWithEventType:EventTypeAccepted];
    self.statusLabel.text = @"accepted";
    self.statusImageView.image = [UIImage imageNamed:@"accepted"];
}

#pragma mark ACTIONS

- (IBAction)denyButtonPressed:(id)sender {
    self.buttonPressedHandler(self.currentEvent, NO);
}

- (IBAction)acceptButtonPressed:(id)sender {
    self.buttonPressedHandler(self.currentEvent, YES);
}


@end

