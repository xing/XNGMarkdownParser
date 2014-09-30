#import "XNGMarkdownTestViewController.h"
#import <XNGMarkdownParser/XNGMarkdownParser.h>

@interface XNGMarkdownTestViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation XNGMarkdownTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextView];
    [self setupMarkDownAttributedString];
}

- (void)setupTextView {
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textView.editable = NO;
    self.textView.selectable = YES;
    [self.view addSubview:self.textView];
}

- (void)setupMarkDownAttributedString {
    NSString *markdown = @"hTTp://www.xing.com esto es una frase en medio http://www.xing.com ";
    
    NSUInteger times = 1;
    NSMutableString *accum = [[NSMutableString alloc] initWithCapacity:times * markdown.length];
    for (NSUInteger i = 0; i < times; ++i) {
        [accum appendString:markdown];
    }

    NSLog(@"BEGIN, parsing string (length %zd)...", accum.length);
    NSDate *begin = [NSDate date];

    XNGMarkdownParser *parser = [[XNGMarkdownParser alloc] init];

    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.minimumLineHeight = 50;

    NSAttributedString *attr = [parser attributedStringFromMarkdownString:accum];

    NSDate *end = [NSDate date];
    NSTimeInterval timeDif = end.timeIntervalSince1970 - begin.timeIntervalSince1970;
    NSLog(@"time to format: %.0f ms", timeDif * 1000);

    self.textView.attributedText = attr;
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.view.frame;
    frame.origin.y = 20;
    frame.size.height -= 20;
    self.textView.frame = frame;
}

@end
