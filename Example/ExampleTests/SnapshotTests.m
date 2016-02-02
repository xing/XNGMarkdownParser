#import <XCTest/XCTest.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <XNGMarkdownParser/XNGMarkdownParser.h>

@interface ExampleTests : FBSnapshotTestCase

@end

@implementation ExampleTests

- (void)setUp {
    [super setUp];
    self.recordMode = NO;
}

- (void)testLists {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"lists.txt"], nil);
}

- (void)testPlainText {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"plaintext_utf8.txt"], nil);
}

- (void)testHeaders {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"headers.txt"], nil);
}

- (void)testSingleHeader {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"single_header.txt"], nil);
}

- (void)testLinks {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"links.txt"], nil);
}

- (void)testLinksEx {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"links_ex.txt"], nil);
}

- (void)testTextStyles {
    FBSnapshotVerifyView([self labelForMarkdownStringWithDefaultAttributesFromFile:@"text_styles.txt"], nil);
}

- (void)testFontChange {
    NSString *markdown = [self markdownFromFile:@"all_together_short.txt"];

    XNGMarkdownParser *parser = [[XNGMarkdownParser alloc] init];
    parser.paragraphFont = [UIFont fontWithName:@"Damascus" size:15];
    parser.codeFontName = @"Menlo-Regular";
    parser.boldFontName = @"EuphemiaUCAS-Bold";
    parser.linkFontName = @"Futura-Medium";
    [parser setFont:[UIFont fontWithName:@"Copperplate" size:24]
          forHeader:XNGMarkdownParserHeader1];
    NSAttributedString *attr = [parser attributedStringFromMarkdownString:markdown];

    FBSnapshotVerifyView([self defaultLabelWithAttributedString:attr], nil);
}

- (void)testParagraphAttributes {
    UILabel *label = [self defaultTextLabel];
    NSString *markdown = [self markdownFromFile:@"paragraph_1.txt"];

    XNGMarkdownParser *parser = [[XNGMarkdownParser alloc] init];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.5, 0.5);
    shadow.shadowBlurRadius = 0.5;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;
    parser.topAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor],
                             NSShadowAttributeName: shadow,
                             NSParagraphStyleAttributeName: paragraphStyle};
    label.attributedText = [parser attributedStringFromMarkdownString:markdown];

    FBSnapshotVerifyView(label, nil);
}

#pragma mark - Helper methods

- (UILabel *)labelForMarkdownStringWithDefaultAttributesFromFile:(NSString *)fileName {
    UILabel *label = [self defaultTextLabel];
    NSAttributedString *attrString = [self parseWithDefaultAttributes:[self markdownFromFile:fileName]];
    [self setAttributedTextAndResizeAutomatically:attrString
                                          inLabel:label];
    return label;
}

- (UILabel *)defaultLabelWithAttributedString:(NSAttributedString *)attr {
    UILabel *label = [self defaultTextLabel];
    [self setAttributedTextAndResizeAutomatically:attr inLabel:label];
    return label;
}

- (void)setAttributedTextAndResizeAutomatically:(NSAttributedString *)attrString
                                        inLabel:(UILabel *)view {
    view.attributedText = attrString;
    CGSize size = [view sizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [view setNeedsLayout];
    [view layoutIfNeeded];
}

- (UILabel *)defaultTextLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (NSString *)markdownFromFile:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *path = [bundle pathForResource:name ofType:nil];
    NSString *markdown = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return markdown;
}

- (NSAttributedString *)parseWithDefaultAttributes:(NSString *)markdown {
    XNGMarkdownParser *parser = [[XNGMarkdownParser alloc] init];
    return [parser attributedStringFromMarkdownString:markdown];
}

@end
