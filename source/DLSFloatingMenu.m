#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DLSGameBridge.h"

// UI implementation only. Gameplay and anti behavior are delegated to DLSGameBridge.
// No key validation, network calls, code-signature changes or anti-cheat bypasses are included.

@interface DLSPassThroughWindow : UIWindow
@property (nonatomic, weak) UIView *orb;
@property (nonatomic, weak) UIView *panel;
@end
@implementation DLSPassThroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (!hit || hit == self || hit == self.rootViewController.view) return nil;
    return hit;
}
@end

@interface DLSFlowButton : UIButton
@property (nonatomic, strong) CAGradientLayer *gradient;
- (instancetype)initWithTitle:(NSString *)title symbol:(NSString *)symbol;
@end
@implementation DLSFlowButton
- (instancetype)initWithTitle:(NSString *)title symbol:(NSString *)symbol {
    if ((self = [super initWithFrame:CGRectZero])) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithRed:0.06 green:0.11 blue:0.19 alpha:1];
        self.layer.cornerRadius = 14;
        self.layer.masksToBounds = YES;
        self.gradient = [CAGradientLayer layer];
        self.gradient.colors = @[(id)[UIColor colorWithRed:0.09 green:0.53 blue:0.98 alpha:1].CGColor,
                                 (id)[UIColor colorWithRed:0.11 green:0.89 blue:0.73 alpha:1].CGColor,
                                 (id)[UIColor colorWithRed:0.37 green:0.28 blue:0.93 alpha:1].CGColor,
                                 (id)[UIColor colorWithRed:0.09 green:0.53 blue:0.98 alpha:1].CGColor];
        self.gradient.startPoint = CGPointMake(0, 0.3);
        self.gradient.endPoint = CGPointMake(1, 0.7);
        self.gradient.locations = @[@0.0, @0.36, @0.72, @1.0];
        [self.layer insertSublayer:self.gradient atIndex:0];
        CABasicAnimation *flow = [CABasicAnimation animationWithKeyPath:@"startPoint"];
        flow.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.2)];
        flow.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.9)];
        flow.duration = 5.2;
        flow.autoreverses = YES;
        flow.repeatCount = HUGE_VALF;
        [self.gradient addAnimation:flow forKey:@"waterFlow"];
        self.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        self.tintColor = UIColor.whiteColor;
        [self setTitle:[NSString stringWithFormat:@"%@   %@", symbol, title] forState:UIControlStateNormal];
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradient.frame = self.bounds;
}
@end

@interface DLSFloatingMenu : NSObject
@property (nonatomic, strong) DLSPassThroughWindow *window;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIView *orb;
@property (nonatomic, strong) CAGradientLayer *orbGradient;
@property (nonatomic, strong) UILabel *antiState;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, strong) NSLayoutConstraint *orbLeading;
@property (nonatomic, strong) NSLayoutConstraint *orbTop;
@property (nonatomic, assign) BOOL menuOpen;
+ (instancetype)shared;
- (void)start;
@end

@implementation DLSFloatingMenu
+ (instancetype)shared {
    static DLSFloatingMenu *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [DLSFloatingMenu new]; });
    return instance;
}

- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight color:(UIColor *)color {
    UILabel *v = [UILabel new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.text = text;
    v.font = [UIFont systemFontOfSize:size weight:weight];
    v.textColor = color;
    return v;
}

- (void)start {
    if (self.window) return;
    UIWindowScene *scene = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *candidate in UIApplication.sharedApplication.connectedScenes) {
            if ([candidate isKindOfClass:[UIWindowScene class]] &&
                candidate.activationState == UISceneActivationStateForegroundActive) {
                scene = (UIWindowScene *)candidate;
                break;
            }
        }
        if (!scene) return; // Retry on scene activation if launched before scene connects.
        self.window = [[DLSPassThroughWindow alloc] initWithWindowScene:scene];
    } else {
        self.window = [[DLSPassThroughWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    self.window.windowLevel = UIWindowLevelAlert + 1;
    self.window.backgroundColor = UIColor.clearColor;
    UIViewController *root = [UIViewController new];
    root.view.backgroundColor = UIColor.clearColor;
    self.window.rootViewController = root;
    self.window.hidden = NO; // Do not take key-window focus away from the game.
    UIView *canvas = root.view;

    self.orb = [UIView new];
    self.orb.translatesAutoresizingMaskIntoConstraints = NO;
    self.orb.layer.cornerRadius = 29;
    self.orb.layer.masksToBounds = YES;
    self.orb.backgroundColor = [UIColor colorWithRed:0.09 green:0.12 blue:0.20 alpha:1];
    [canvas addSubview:self.orb];
    self.orbLeading = [self.orb.leadingAnchor constraintEqualToAnchor:canvas.safeAreaLayoutGuide.leadingAnchor constant:14];
    self.orbTop = [self.orb.topAnchor constraintEqualToAnchor:canvas.safeAreaLayoutGuide.topAnchor constant:125];
    [NSLayoutConstraint activateConstraints:@[self.orbLeading, self.orbTop,
      [self.orb.widthAnchor constraintEqualToConstant:58], [self.orb.heightAnchor constraintEqualToConstant:58]]];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor colorWithRed:0.10 green:0.72 blue:0.95 alpha:1].CGColor,
                        (id)[UIColor colorWithRed:0.16 green:0.88 blue:0.61 alpha:1].CGColor,
                        (id)[UIColor colorWithRed:0.40 green:0.25 blue:0.94 alpha:1].CGColor,
                        (id)[UIColor colorWithRed:0.10 green:0.72 blue:0.95 alpha:1].CGColor];
    gradient.frame = CGRectMake(0, 0, 58, 58);
    gradient.startPoint = CGPointMake(0, 0.3);
    gradient.endPoint = CGPointMake(1, 0.7);
    gradient.locations = @[@0, @0.30, @0.68, @1];
    [self.orb.layer insertSublayer:gradient atIndex:0];
    self.orbGradient = gradient;
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"startPoint"];
    move.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.2)];
    move.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.8)];
    move.duration = 4.0;
    move.autoreverses = YES;
    move.repeatCount = HUGE_VALF;
    [gradient addAnimation:move forKey:@"fluid"];

    UILabel *icon = [self label:@"⚽" size:24 weight:UIFontWeightBold color:UIColor.whiteColor];
    icon.textAlignment = NSTextAlignmentCenter;
    [self.orb addSubview:icon];
    [NSLayoutConstraint activateConstraints:@[[icon.centerXAnchor constraintEqualToAnchor:self.orb.centerXAnchor],
      [icon.centerYAnchor constraintEqualToAnchor:self.orb.centerYAnchor]]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [self.orb addGestureRecognizer:tap];
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveOrb:)];
    [self.orb addGestureRecognizer:drag];

    self.panel = [UIView new];
    self.panel.translatesAutoresizingMaskIntoConstraints = NO;
    self.panel.backgroundColor = [UIColor colorWithRed:0.055 green:0.075 blue:0.13 alpha:0.97];
    self.panel.layer.cornerRadius = 20;
    self.panel.layer.borderWidth = 1;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.20 green:0.38 blue:0.47 alpha:0.8].CGColor;
    self.panel.layer.shadowColor = UIColor.blackColor.CGColor;
    self.panel.layer.shadowOpacity = 0.40;
    self.panel.layer.shadowRadius = 20;
    [canvas addSubview:self.panel];
    [NSLayoutConstraint activateConstraints:@[
       [self.panel.widthAnchor constraintEqualToConstant:262],
       [self.panel.heightAnchor constraintEqualToConstant:216],
       [self.panel.centerYAnchor constraintEqualToAnchor:canvas.centerYAnchor],
       [self.panel.centerXAnchor constraintEqualToAnchor:canvas.centerXAnchor]]];

    UILabel *title = [self label:@"DLS  /  MATCH TOOLS" size:15 weight:UIFontWeightBold color:UIColor.whiteColor];
    [self.panel addSubview:title];
    [NSLayoutConstraint activateConstraints:@[[title.leadingAnchor constraintEqualToAnchor:self.panel.leadingAnchor constant:18],
      [title.topAnchor constraintEqualToAnchor:self.panel.topAnchor constant:18]]];
    self.statusDot = [UIView new];
    self.statusDot.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusDot.backgroundColor = [UIColor colorWithRed:0.98 green:0.75 blue:0.35 alpha:1];
    self.statusDot.layer.cornerRadius = 4;
    [self.panel addSubview:self.statusDot];
    [NSLayoutConstraint activateConstraints:@[[self.statusDot.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
     [self.statusDot.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:15],
     [self.statusDot.widthAnchor constraintEqualToConstant:8],
     [self.statusDot.heightAnchor constraintEqualToConstant:8]]];
    self.antiState = [self label:@"Anti: đang kiểm tra…" size:12 weight:UIFontWeightMedium
                        color:[UIColor colorWithWhite:0.73 alpha:1]];
    [self.panel addSubview:self.antiState];
    [NSLayoutConstraint activateConstraints:@[[self.antiState.leadingAnchor constraintEqualToAnchor:self.statusDot.trailingAnchor constant:8],
     [self.antiState.centerYAnchor constraintEqualToAnchor:self.statusDot.centerYAnchor]]];

    DLSFlowButton *endButton = [[DLSFlowButton alloc] initWithTitle:@"KẾT THÚC TRẬN" symbol:@"⏱"];
    [self.panel addSubview:endButton];
    [endButton addTarget:self action:@selector(endMatch) forControlEvents:UIControlEventTouchUpInside];
    DLSFlowButton *goalButton = [[DLSFlowButton alloc] initWithTitle:@"+1 BÀN THẮNG" symbol:@"⚽"];
    [self.panel addSubview:goalButton];
    [goalButton addTarget:self action:@selector(addGoal) forControlEvents:UIControlEventTouchUpInside];
    [NSLayoutConstraint activateConstraints:@[
       [endButton.topAnchor constraintEqualToAnchor:self.antiState.bottomAnchor constant:18],
       [endButton.leadingAnchor constraintEqualToAnchor:self.panel.leadingAnchor constant:16],
       [endButton.trailingAnchor constraintEqualToAnchor:self.panel.trailingAnchor constant:-16],
       [endButton.heightAnchor constraintEqualToConstant:48],
       [goalButton.topAnchor constraintEqualToAnchor:endButton.bottomAnchor constant:10],
       [goalButton.leadingAnchor constraintEqualToAnchor:endButton.leadingAnchor],
       [goalButton.trailingAnchor constraintEqualToAnchor:endButton.trailingAnchor],
       [goalButton.heightAnchor constraintEqualToConstant:48]]];

    self.panel.hidden = YES;
    self.window.orb = self.orb;
    self.window.panel = self.panel;

    // Anti starts as soon as the overlay is mounted. A success popup is SHOWN ONLY ON TRUE.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSError *error = nil;
        BOOL active = DLSGameBridgeStartAnti(&error);
        NSString *message = error.localizedDescription;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.antiState.text = active ? @"Anti: đã xác nhận" : @"Anti: chưa khả dụng";
            self.statusDot.backgroundColor = active ? [UIColor colorWithRed:0.26 green:0.90 blue:0.58 alpha:1]
                                                   : [UIColor colorWithRed:1 green:0.42 blue:0.40 alpha:1];
            if (active) [self showPopup:@"Anti đã kích hoạt thành công" detail:@"Trạng thái đã được xác nhận."];
            else NSLog(@"[DLSMatchMenu] Anti chưa thể xác nhận: %@", message ?: @"No result");
        });
    });
}

- (void)toggleMenu {
    self.menuOpen = !self.menuOpen;
    self.panel.hidden = !self.menuOpen;
    self.panel.transform = self.menuOpen ? CGAffineTransformMakeScale(0.92, 0.92) : CGAffineTransformIdentity;
    if (self.menuOpen) {
        [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.panel.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)moveOrb:(UIPanGestureRecognizer *)gesture {
    CGPoint movement = [gesture translationInView:self.window.rootViewController.view];
    CGRect bounds = self.window.bounds;
    CGFloat maxX = MAX(8, bounds.size.width - 70);
    CGFloat maxY = MAX(8, bounds.size.height - 110);
    self.orbLeading.constant = MIN(MAX(8, self.orbLeading.constant + movement.x), maxX);
    self.orbTop.constant = MIN(MAX(8, self.orbTop.constant + movement.y), maxY);
    [gesture setTranslation:CGPointZero inView:self.window.rootViewController.view];
}

- (void)showPopup:(NSString *)title detail:(NSString *)detail {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
        message:detail preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}
- (void)endMatch {
    NSError *error = nil;
    BOOL accepted = DLSGameBridgeEndMatch(&error);
    [self showPopup:accepted ? @"Đã gửi lệnh kết thúc trận" : @"Chưa thể kết thúc trận"
             detail:accepted ? @"Cần kiểm tra kết quả cuối trận trong DLS." : (error.localizedDescription ?: @"Không có bộ xử lý DLS.")];
}
- (void)addGoal {
    NSError *error = nil;
    BOOL accepted = DLSGameBridgeAddHomeTeamGoal(&error);
    [self showPopup:accepted ? @"Đã gửi yêu cầu +1 bàn" : @"Chưa thể cộng bàn"
             detail:accepted ? @"Cần đối chiếu tỉ số thực tế trong DLS." : (error.localizedDescription ?: @"Không có bộ xử lý DLS.")];
}
@end

__attribute__((constructor)) static void DLSInitializeMenu(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DLSFloatingMenu shared] start];
        [[NSNotificationCenter defaultCenter] addObserverForName:UISceneDidActivateNotification
                                                          object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
            [[DLSFloatingMenu shared] start];
        }];
    });
}
