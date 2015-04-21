#include <notify.h>

/*
Text her: “Hey babe, can I ask you something?”
When I register that she has opened that view controller, delay~3 seconds and then fade her screen to a black view
A few seconds after that, have a few hearts and the words “Prom?” animate from the top of the screen, followed by two buttons, “Yes” and “No” from the bottom.
When she clicks “Yes”, that view will fade away (leaving the black view) and balloons will float up from the bottom of the scren, and a couple seconds later the black view will fade away, and the UITextView will have “Yes!” inputted into it

Or I could just show an alert view “Looks like you clicked the wrong button. Please try again” until she hits yes XD
*/

#ifdef DEBUG
#define NSLog(FORMAT, ...) NSLog(@"[SpringTweak] %@", [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])

#else
#define NSLog(FORMAT, ...) do {} while (0);
#endif

//I refrained from using global variables up until now, but she's going to be home in 15 minutes and I need to finish
UIWindow* promposeWindow;

@interface PTPromposalBalloonView : UIView
@property (nonatomic, retain, readonly) UIColor* color;
-(id)initWithFrame:(CGRect)frame withBalloonColor:(UIColor*)color;
@end

@implementation PTPromposalBalloonView
-(id)initWithFrame:(CGRect)frame {
	self = [self initWithFrame:frame withBalloonColor:[UIColor redColor]];
	return self;
}
-(id)initWithFrame:(CGRect)frame withBalloonColor:(UIColor*)color {
	if (self = [super initWithFrame:frame]) {
		//these next few lines are bad
		//i am tired
		NSString* colorToUse;
		if (color == [UIColor redColor]) colorToUse = @"Red";
		else if (color == [UIColor greenColor]) colorToUse = @"Green";
		else if (color == [UIColor blueColor]) colorToUse = @"Blue";
		else if (color == [UIColor orangeColor]) colorToUse = @"Orange";
		else colorToUse = @"Pink";
		UIImageView* balloon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/Application Support/Spring/Balloon-%@.png", colorToUse]]];
		balloon.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/5);
		balloon.center = CGPointMake(self.center.x, balloon.center.y);
		[self addSubview:balloon];

		//[self setNeedsDisplay];

		//the frame we have to work with 
		//the whole frame minus the balloon

		//we add some offsets because uibezierpath is dumb and i hate myself
		CGRect remainingSize = CGRectMake(0, balloon.frame.size.height, self.frame.size.width, self.frame.size.height - balloon.frame.size.height);

		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(remainingSize.size.width/2, remainingSize.origin.y)];
		//CGFloat lineOffset = 30;
		//[path addLineToPoint:CGPointMake(remainingSize.size.width/2, remainingSize.origin.y)];

		//remainingSize = CGRectMake(0, balloon.frame.size.height - lineOffset, self.frame.size.width, self.frame.size.height - balloon.frame.size.height - lineOffset);
		//[path addQuadCurveToPoint:CGPointMake(remainingSize.size.width/2, remainingSize.size.height/3) controlPoint:CGPointMake(remainingSize.size.width, remainingSize.size.height/6)];
		[path addQuadCurveToPoint:CGPointMake(remainingSize.size.width/2, (remainingSize.size.height/3)*2) controlPoint:CGPointMake(0, (remainingSize.size.height/6)*3)];
		[path addQuadCurveToPoint:CGPointMake(remainingSize.size.width/2, remainingSize.size.height) controlPoint:CGPointMake(remainingSize.size.width, (remainingSize.size.height/6)*5)];

		CAShapeLayer *layer = [CAShapeLayer layer];
		layer.lineWidth = 1;
		layer.strokeColor = [UIColor darkGrayColor].CGColor;
		layer.fillColor = [UIColor clearColor].CGColor;
		layer.path = path.CGPath;

		[self.layer addSublayer:layer];
	}
	return self;
}
@end

//it is recommended, though not required, you use this view with the full screen size
@interface PTPromposalView : UIView
-(void)displayPromposal;
-(void)yesButtonPressed:(UIButton*)sender;
-(void)noButtonPressed:(UIButton*)sender;
@end 

@implementation PTPromposalView

//This is being used as the entry point because Ethan has not yet provided me with the 'proper' entry point 
//(i.e. when the desired message is viewed in Messages.app)
-(void)displayPromposal {
	//This window blocks touches for a couple seconds so they cant exit the view
	self.userInteractionEnabled = YES;
	//[[[UIApplication sharedApplication] keyWindow] addSubview:self];

	//Delay the showing of our view for a second or so
	//Let her read my text
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		//We'll keep the touch blocking view around for now so she doesnt accidentally exit this

		//Actually, let's add everything to that!
		UIView* backgroundView = [[UIView alloc] initWithFrame:self.frame];
		backgroundView.tag = 133742069;
		backgroundView.backgroundColor = [UIColor whiteColor];
		backgroundView.alpha = 0.0;
		[self addSubview:backgroundView];

		PTPromposalBalloonView* balloon = [[PTPromposalBalloonView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4, self.frame.size.height*0.75)];
		balloon.center = self.center;
		balloon.opaque = NO;
		//[self addSubview:balloon];

		[UIView animateWithDuration:1.25 animations:^{
			backgroundView.alpha = 1.0;
		} completion:^(BOOL finished){
			if (finished) {
				//Give them a second to process what just happened
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
					//animator which wil be used to animate elements
					UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] initWithReferenceView:backgroundView];

					//label which will slide down from top of screen
					//we should probably replace this with a view
					//from hoe near :D
					UIImageView* label = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Spring/Text.png"]];
					label.frame = CGRectMake(0, 0, self.frame.size.width*0.75, self.frame.size.height/5);
					label.center = CGPointMake(self.center.x, -self.center.y);;
					[backgroundView addSubview:label];

					//heart shape left
					UIImageView* leftHeart = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Spring/leftHeart.png"]];
					leftHeart.frame = CGRectMake(0, 0, self.frame.size.width/5, self.frame.size.width/5);
					leftHeart.center = CGPointMake(self.frame.size.width*0.125, -self.center.y);
					[backgroundView insertSubview:leftHeart belowSubview:label];

					//heart shape right
					UIImageView* rightHeart = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Spring/rightHeart.png"]];
					rightHeart.frame = CGRectMake(0, 0, self.frame.size.width/4, self.frame.size.width/4);
					rightHeart.center = CGPointMake(self.frame.size.width*0.85, -self.center.y);
					[backgroundView insertSubview:rightHeart belowSubview:label];

					//snap behavior for label
					UISnapBehavior* mainLabelSnapBehavior = [[UISnapBehavior alloc] initWithItem:label snapToPoint:CGPointMake(label.center.x, self.center.y * 0.65)];
					[animator addBehavior:mainLabelSnapBehavior];

					//We create the behaviors for the left and right hearts here, but we want them to fall down a fraction of a second later
					UISnapBehavior* leftHeartSnapBehavior = [[UISnapBehavior alloc] initWithItem:leftHeart snapToPoint:CGPointMake(leftHeart.center.x, self.center.y * 0.67)];
					UISnapBehavior* rightHeartSnapBehavior = [[UISnapBehavior alloc] initWithItem:rightHeart snapToPoint:CGPointMake(rightHeart.center.x, self.center.y * 0.60)];

					//wait for the label to appear
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
						[animator addBehavior:leftHeartSnapBehavior];

						//wait for that heart to fall a little
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
							[animator addBehavior:rightHeartSnapBehavior];

							//Now, show the 'Yes/No' buttons
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
								UIButton* yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
								[yesButton addTarget:self action:@selector(yesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
								[yesButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Spring/YesButton.png"] forState:UIControlStateNormal];
								yesButton.frame = CGRectMake(0, 0, self.frame.size.width*0.4, self.frame.size.height*0.06);
								yesButton.center = CGPointMake(self.center.x/2, self.frame.size.height*1.5);
								[backgroundView addSubview:yesButton];

								UIButton* noButton = [UIButton buttonWithType:UIButtonTypeCustom];
								[noButton addTarget:self action:@selector(noButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
								[noButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Spring/NoButton.png"] forState:UIControlStateNormal];
								noButton.frame = CGRectMake(0, 0, self.frame.size.width*0.4, self.frame.size.height*0.06);
								noButton.center = CGPointMake(self.center.x*1.50, self.frame.size.height*1.5);
								[backgroundView addSubview:noButton];

								//Create the behaviors here, but the no button begins animating very slightly after the yes button
								//all of these delays are in the name of liveliness

								UISnapBehavior* yesButtonSnapBehavior = [[UISnapBehavior alloc] initWithItem:yesButton snapToPoint:CGPointMake(yesButton.center.x, self.frame.size.height*0.85)];
								UISnapBehavior* noButtonSnapBehavior = [[UISnapBehavior alloc] initWithItem:noButton snapToPoint:CGPointMake(noButton.center.x, self.frame.size.height*0.85)];

								//add the left one
								[animator addBehavior:yesButtonSnapBehavior];

								//slightly delay the right one
								dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
									[animator addBehavior:noButtonSnapBehavior];
								});
							});
						});
					});
				});
			}
		}];
	});
}

-(void)yesButtonPressed:(UIButton*)sender {
	//Mission accomplished!

	//begin fade out when the below animation is beginning to finish
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:1.0 animations:^{
			self.alpha = 0.0;
		} completion:^(BOOL finished){
			if (finished) {
				[self removeFromSuperview];

				//please tell me theres a better way to do this
				promposeWindow.userInteractionEnabled = NO;
				promposeWindow.windowLevel = 0;
				[promposeWindow removeFromSuperview];
			}
		}];
	});

	UIView* mainView = [self viewWithTag:133742069];

	//balloons for next step
	PTPromposalBalloonView* redBalloon = [[PTPromposalBalloonView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/5, self.frame.size.height*0.6) withBalloonColor:[UIColor redColor]];
	redBalloon.center = CGPointMake(self.frame.size.width*0.15, self.frame.size.height*1.6);
	[mainView addSubview:redBalloon];
	PTPromposalBalloonView* blueBalloon = [[PTPromposalBalloonView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/5, self.frame.size.height*0.6) withBalloonColor:[UIColor blueColor]];
	blueBalloon.center = CGPointMake(self.frame.size.width*0.45, self.frame.size.height*1.4);
	[mainView addSubview:blueBalloon];
	PTPromposalBalloonView* greenBalloon = [[PTPromposalBalloonView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/5, self.frame.size.height*0.6) withBalloonColor:[UIColor greenColor]];
	greenBalloon.center = CGPointMake(self.frame.size.width*0.8, self.frame.size.height*1.85);
	[mainView addSubview:greenBalloon];

	//slide up and show balloons
	[UIView animateWithDuration:7.5 animations:^{
		for (UIView* subview in [mainView subviews]) {
			subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y - (self.frame.size.height*2), subview.frame.size.width, subview.frame.size.height);
		}
		
	}];
}
-(void)noButtonPressed:(UIButton*)sender {
	//Never give up. 
	//Never surrender.
	[[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Looks like you touched the wrong button. Please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

@end

//hook

@interface TUPhoneNumber
+ (id)phoneNumberWithCFPhoneNumberRef:(id)arg1;
- (id)digits;
@end

@interface IMHandle
- (id)phoneNumberRef;
@end

BOOL hasPromposed = NO;

%hook IMChatRegistry

-(void)_chat_sendReadReceiptForAllMessages:(id)arg1 {
	%log;
	id chat = arg1;
	id message = [chat performSelector:@selector(lastMessage)];
	id text = [message performSelector:@selector(text)];
	NSString *triggerString = @"Hey babe, can I ask you a question?";

	if ([[text performSelector:@selector(string)] isEqualToString:triggerString] && !hasPromposed) {
		//This is the moment we've all been waiting for, boys!
		NSLog(@"AYYY LMAO");
		hasPromposed = YES;

		notify_post("com.phillipt.prompose");
	}
	%orig;
}

%end
/*
%hook IMMessage
/*
-(id)initWithSender:(id)arg1 time:(id)arg2 text:(id)arg3 messageSubject:(id)arg4 fileTransferGUIDs:(id)arg5 flags:(unsigned long long)arg6 error:(id)arg7 guid:(id)arg8 subject:(id)arg9 {
	%log;
	return %orig;
}
-(id)initWithSender:(id)arg1 time:(id)arg2 text:(id)arg3 fileTransferGUIDs:(id)arg4 flags:(unsigned long long)arg5 error:(id)arg6 guid:(id)arg7 subject:(id)arg8 {
	%log;
	return %orig;
}
-(id)initWithSender:(id)arg1 fileTransfer:(id)arg2 {
	%log;
	return %orig;
}
*/
/*
BOOL hasPromposed = NO;
- (id)_initWithSender:(IMHandle *)arg1 time:(id)arg2 timeRead:(id)arg3 timeDelivered:(id)arg4 timePlayed:(id)arg5 plainText:(id)arg6 text:(id)arg7 messageSubject:(id)arg8 fileTransferGUIDs:(id)arg9 flags:(unsigned long long)arg10 error:(id)arg11 guid:(id)arg12 messageID:(long long)arg13 subject:(id)arg14 {

	//%log;
	
	NSString *contactNumber = @"1111111111";
	NSString *triggerString = @"Hey babe, can I ask you a question?";

	//get number
	NSString *curNum = [[objc_getClass("TUPhoneNumber") phoneNumberWithCFPhoneNumberRef:[arg1 phoneNumberRef]] digits];
	
	//remove +1 from it
	curNum = [curNum stringByReplacingOccurrencesOfString:@"+1" withString:@""];

	//check if we've already asked them to prom
	//BOOL hasPromposed = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPromposed"];

	//if its the magic text & havent triggered yet
	if (/*[curNum isEqualToString:contactNumber] &&*/ /*[[arg7 string] isEqualToString:triggerString] && arg3 && !hasPromposed) {
		//This is the moment we've all been waiting for, boys!
		NSLog(@"AYYY LMAO");
		hasPromposed = YES;
		//[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"hasPromposed"];
		//[[NSUserDefaults standardUserDefaults] synchronize];

		notify_post("com.phillipt.prompose");
	}

	return %orig;
}

%end
*/
void prompose() {
	NSLog(@"Promopsing...");
	promposeWindow = [[UIWindow alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
	//we display an alert so it needs to be under alerts
	promposeWindow.windowLevel = UIWindowLevelAlert - 1;
	[promposeWindow makeKeyAndVisible];
	PTPromposalView* promposalView = [[PTPromposalView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
	[promposeWindow addSubview:promposalView];

	[promposalView displayPromposal];
}

%hook SpringBoard 
-(void)applicationDidFinishLaunching:(id)application {
	%orig;
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)prompose,
									CFSTR("com.phillipt.prompose"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
}
%end
/*
%ctor {
	//listen for notification
	NSString* currOpen = [[[UIApplication sharedApplication] performSelector:@selector(_accessibilityFrontMostApplication)] performSelector:@selector(bundleIdentifier)];
	NSLog(@"currOpen: %@", currOpen);
	if ([currOpen isEqualToString:@"com.apple.springboard"]) {
		
	}
}
*/
