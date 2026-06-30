#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ==================== CONFIG ====================
@interface IAPCrackerConfig : NSObject
@property (nonatomic, assign) BOOL genericHooks;
@property (nonatomic, assign) BOOL revenueCatHooks;
@property (nonatomic, assign) BOOL storeKitHooks;
@property (nonatomic, assign) BOOL swiftyStoreKitHooks;
@property (nonatomic, assign) BOOL antiDetection;
@property (nonatomic, assign) BOOL receiptBypass;
@property (nonatomic, assign) BOOL showMenuOnLaunch;
@property (nonatomic, assign) BOOL debugLogging;
@end

@implementation IAPCrackerConfig
+ (instancetype)shared {
    static IAPCrackerConfig *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        shared.genericHooks = YES;
        shared.revenueCatHooks = YES;
        shared.storeKitHooks = YES;
        shared.swiftyStoreKitHooks = YES;
        shared.antiDetection = YES;
        shared.receiptBypass = YES;
        shared.showMenuOnLaunch = YES;
        shared.debugLogging = NO;
    });
    return shared;
}
@end

// ==================== MENU ====================
@interface IAPCrackerMenu : UIWindow
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation IAPCrackerMenu

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 100;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 70, 310, 480)];
        self.scrollView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.97];
        self.scrollView.layer.cornerRadius = 16;
        self.scrollView.layer.borderWidth = 1.5;
        self.scrollView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.scrollView];
        
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    CGFloat y = 20.0;
    NSArray *titles = @[@"Generic Hooks", @"RevenueCat", @"StoreKit", @"SwiftyStoreKit", 
                       @"Anti-Detection", @"Receipt Bypass", @"Show on Launch", @"Debug Logging"];
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 190, 35)];
        lbl.text = titles[i];
        lbl.textColor = [UIColor whiteColor];
        [self.scrollView addSubview:lbl];
        
        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(230, y + 3, 70, 30)];
        sw.tag = i;
        sw.on = [self currentStateForIndex:i];
        [sw addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:sw];
        
        y += 55;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, y + 30, 110, 50);
    [btn setTitle:@"Close" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btn];
    
    self.scrollView.contentSize = CGSizeMake(310, y + 120);
}

- (BOOL)currentStateForIndex:(NSInteger)idx {
    IAPCrackerConfig *c = [IAPCrackerConfig shared];
    switch (idx) {
        case 0: return c.genericHooks;
        case 1: return c.revenueCatHooks;
        case 2: return c.storeKitHooks;
        case 3: return c.swiftyStoreKitHooks;
        case 4: return c.antiDetection;
        case 5: return c.receiptBypass;
        case 6: return c.showMenuOnLaunch;
        case 7: return c.debugLogging;
    }
    return YES;
}

- (void)switchToggled:(UISwitch *)sw {
    IAPCrackerConfig *c = [IAPCrackerConfig shared];
    switch (sw.tag) {
        case 0: c.genericHooks = sw.on; break;
        case 1: c.revenueCatHooks = sw.on; break;
        case 2: c.storeKitHooks = sw.on; break;
        case 3: c.swiftyStoreKitHooks = sw.on; break;
        case 4: c.antiDetection = sw.on; break;
        case 5: c.receiptBypass = sw.on; break;
        case 6: c.showMenuOnLaunch = sw.on; break;
        case 7: c.debugLogging = sw.on; break;
    }
}

- (void)closeMenu {
    self.hidden = YES;
}
@end

// ==================== SHAKE GESTURE ====================
%hook UIWindow
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        static IAPCrackerMenu *menu = nil;
        if (!menu) menu = [[IAPCrackerMenu alloc] init];
        menu.hidden = !menu.hidden;
        if (!menu.hidden) [menu makeKeyAndVisible];
    }
    %orig;
}
%end

// ==================== FORCED HOOKS ====================
static BOOL forcedYes(id self, SEL _cmd) { return YES; }
static NSData *dummyReceipt(id self, SEL _cmd) { return [NSData data]; }

// ==================== INIT ====================
__attribute__((constructor))
static void UniversalIAPCrackerInit() {
    NSLog(@"[UniversalIAPCracker] Loaded - Shake device to open menu");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([IAPCrackerConfig shared].showMenuOnLaunch) {
            IAPCrackerMenu *menu = [[IAPCrackerMenu alloc] init];
            menu.hidden = NO;
            [menu makeKeyAndVisible];
        }
    });
}
