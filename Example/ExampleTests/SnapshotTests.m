#import <XCTest/XCTest.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <XNGMarkdownParser/XNGMarkdownParser.h>

@interface ExampleTests : FBSnapshotTestCase

@end

@implementation ExampleTests

- (void) setUp {
    [super setUp];
    self.recordMode = NO;
}

- (void)testPlainText {
    FBSnapshotVerifyView([self textViewForMarkdownStringWithDefaultAttributesFromFile:@"plaintext_utf8.txt"], nil);
}

- (void)testHeaders {
    FBSnapshotVerifyView([self textViewForMarkdownStringWithDefaultAttributesFromFile:@"headers.txt"], nil);
}

- (void)testLinks {
    FBSnapshotVerifyView([self textViewForMarkdownStringWithDefaultAttributesFromFile:@"links.txt"], nil);
}

- (void)testTextStyles {
    FBSnapshotVerifyView([self textViewForMarkdownStringWithDefaultAttributesFromFile:@"text_styles.txt"], nil);
}

- (void)testFontChange {
    NSString *markdown = [self markdownFromFile:@"all_together_short.txt"];

    XNGMarkdownParser * parser = [[XNGMarkdownParser alloc] init];
    parser.paragraphFont = [UIFont fontWithName:@"Damascus" size:15];
    parser.codeFontName = @"Menlo-Regular";
    parser.boldFontName = @"EuphemiaUCAS-Bold";
    parser.linkFontName = @"Futura-Medium";
    [parser setFont:[UIFont fontWithName:@"Copperplate" size:24]
          forHeader:XNGMarkdownParserHeader1];
    NSAttributedString * attr = [parser attributedStringFromMarkdownString:markdown];

    FBSnapshotVerifyView([self defaultTextViewWithAttributedString:attr], nil);
}

- (void)testParagraphAttributes {
    UITextView *textView = [self defaultTextView];
    NSString * markdown = [self markdownFromFile:@"paragraph_1.txt"];

    XNGMarkdownParser *parser = [[XNGMarkdownParser alloc] init];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.5, 0.5);
    shadow.shadowBlurRadius = 0.5;
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;
    parser.topAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor],
                             NSShadowAttributeName : shadow,
                             NSParagraphStyleAttributeName : paragraphStyle,
                             };
    textView.attributedText = [parser attributedStringFromMarkdownString:markdown];

    FBSnapshotVerifyView(textView, nil);
}

#pragma mark - Helper methods

- (UITextView*) textViewForMarkdownStringWithDefaultAttributesFromFile:(NSString*)fileName {
    UITextView *textView = [self defaultTextView];
    NSAttributedString * attrString = [self parseWithDefaultAttributes:[self markdownFromFile:fileName]];
    [self setAttributedTextAndResizeAutomatically:attrString
                                       inTextView:textView];
    return textView;
}

- (UITextView*) defaultTextViewWithAttributedString:(NSAttributedString*)attr {
    UITextView * textView = [self defaultTextView];
    [self setAttributedTextAndResizeAutomatically:attr inTextView:textView];
    return textView;
}

- (void)setAttributedTextAndResizeAutomatically:(NSAttributedString*)attrString
                                     inTextView:(UITextView*)view
{
    view.attributedText = attrString;
    CGSize size = [view sizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];
    view.frame = CGRectMake(0, 0, size.width, size.height);
}

- (UITextView *)defaultTextView {
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    tv.editable = NO;
    return tv;
}

- (NSString *)markdownFromFile:(NSString *)name {
    NSBundle * b = [NSBundle bundleForClass:self.class];
    NSString *file = [b pathForResource:name ofType:nil];

    NSString *markdown = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    return markdown;
}

- (NSAttributedString *)parseWithDefaultAttributes:(NSString*)markdown {
    XNGMarkdownParser *parser = [[XNGMarkdownParser alloc] init];
    return [parser attributedStringFromMarkdownString:markdown];
}

@end
