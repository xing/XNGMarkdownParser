#import "XNGMarkdownTestViewController.h"
#import <XNGMarkdownParser/XNGMarkdownParser.h>

@import SafariServices;

typedef NS_ENUM(NSUInteger, XNGMarkdownTestViewControllerMode) {
    XNGMarkdownTestViewControllerModeDisplay,
    XNGMarkdownTestViewControllerModeEditing
};

@interface XNGMarkdownTestViewController () <UITextViewDelegate>

@property (nonatomic) XNGMarkdownTestViewControllerMode mode;
@property (nonatomic) NSString *markdown;
@property (nonatomic) XNGMarkdownParser *markdownParser;
@property (nonatomic) UIBarButtonItem *reloadDefaultButton;
@property (nonatomic) UIBarButtonItem *editButton;
@property (nonatomic) UIBarButtonItem *doneButton;
@property (nonatomic) UITextView *textView;

@end

@implementation XNGMarkdownTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"XNGMarkdownParser";
    [self setupNavigationButtons];
    [self setupTextView];
    [self setupMarkdownParser];

    self.mode = XNGMarkdownTestViewControllerModeDisplay;
    [self reloadDefaultMarkdown:nil];
}

- (void)setMode:(XNGMarkdownTestViewControllerMode)mode {
    switch (mode) {
        case XNGMarkdownTestViewControllerModeDisplay: {
            NSAttributedString *attr = [self.markdownParser attributedStringFromMarkdownString:self.markdown];
            if (attr) {
                self.textView.editable = NO;
                _mode = mode;
                self.textView.attributedText = attr;

                self.navigationItem.leftBarButtonItem = self.reloadDefaultButton;
                self.navigationItem.rightBarButtonItem = self.editButton;
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Please fix your markdown"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
        }
        case XNGMarkdownTestViewControllerModeEditing: {
            _mode = mode;

            self.textView.editable = YES;
            self.textView.text = self.markdown;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = self.doneButton;
            break;
        }
    }
}

#pragma mark - setup methods

- (void)setupNavigationButtons {
    self.reloadDefaultButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(reloadDefaultMarkdown:)];
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(setEditingMode:)];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"done"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(setDisplayMode:)];
}

- (void)setupTextView {
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.selectable = YES;
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
}

- (void)setupMarkdownParser {
    self.markdownParser = [[XNGMarkdownParser alloc] init];

    // customise parser here
}

#pragma mark - Callbacks

- (void)reloadDefaultMarkdown:(id)sender {
    self.markdown = [self markdownFromBundle:@"all_together_short.txt"];
    self.mode = XNGMarkdownTestViewControllerModeDisplay;
}

- (void)setEditingMode:(id)sender {
    self.mode = XNGMarkdownTestViewControllerModeEditing;
}

- (void)setDisplayMode:(id)sender {
    self.markdown = self.textView.text;
    self.mode = XNGMarkdownTestViewControllerModeDisplay;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (![URL.absoluteString hasPrefix:@"http://"]) {
        NSString *URLString = [@"http://" stringByAppendingString:URL.absoluteString];
        URL = [NSURL URLWithString:URLString];
    }
    @try {
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:safariViewController animated:YES completion:nil];
    } @catch (NSException *exception) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unsupported URL"
                                                                       message:URL.absoluteString
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return YES;
}

#pragma mark - Helper methods

- (NSString *)markdownFromBundle:(NSString*)filename {
    NSBundle * bundle = [NSBundle bundleForClass:self.class];
    NSString * path = [bundle pathForResource:filename ofType:nil];
    return [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

@end
