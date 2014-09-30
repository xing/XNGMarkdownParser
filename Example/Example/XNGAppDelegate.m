#import "XNGAppDelegate.h"
#import "XNGMarkdownTestViewController.h"

@implementation XNGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([[self class] isRunningUnitTests]) {
        return YES;
    }
    
    XNGMarkdownTestViewController *viewController = [[XNGMarkdownTestViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

static BOOL RunningTests = NO;

+ (BOOL)isRunningUnitTests {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        NSString *XCInjectBundle = [[[NSProcessInfo processInfo] environment] objectForKey:@"XCInjectBundle"];
        
        RunningTests = [XCInjectBundle hasSuffix:@".xctest"];
        if ([XCInjectBundle.lastPathComponent isEqualToString:@"KIFTests.xctest"]) {
            RunningTests = NO;
        }
    });
    
    return RunningTests;
}


@end
