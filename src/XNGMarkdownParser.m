//
// Copyright 2011-2014 NimbusKit
// Copyright 2014 XING AG
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "XNGMarkdownParser.h"

#import "XNGMarkdownTokens.h"
#import "fmemopen.h"

#import <CoreText/CoreText.h>
#import <pthread.h>

FILE *markdownin;
int xng_markdown_consume(char *text, XNGMarkdownParserCode token, yyscan_t scanner);

@interface XNGMarkdownLink ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSRange range;
@end

@implementation XNGMarkdownLink
@end

@implementation XNGMarkdownParser {
    NSMutableDictionary *_headerFonts;

    NSMutableArray *_bulletStarts;

    NSMutableAttributedString *_accum;
    NSMutableArray *_links;

    UINSFont *_topFont;
    NSMutableDictionary *_fontCache;
}

- (id)init {
    if ((self = [super init])) {
        _headerFonts = [NSMutableDictionary dictionary];

        self.paragraphFont = [UINSFont systemFontOfSize:12];
        self.boldFontName = [UINSFont boldSystemFontOfSize:12].fontName;
        self.italicFontName = @"Helvetica-Oblique";
        self.boldItalicFontName = @"Helvetica-BoldOblique";
        self.codeFontName = @"Courier";
        self.linkFontName = self.paragraphFont.fontName;
        self.topAttributes = nil;
        self.shouldParseLinks = YES;

        XNGMarkdownParserHeader header = XNGMarkdownParserHeader1;
        for (CGFloat headerFontSize = 24; headerFontSize >= 14; headerFontSize -= 2, header++) {
            [self setFont:[UINSFont systemFontOfSize:headerFontSize] forHeader:header];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    XNGMarkdownParser *parser = [[self.class allocWithZone:zone] init];
    parser.paragraphFont = self.paragraphFont;
    parser.boldFontName = self.boldFontName;
    parser.italicFontName = self.italicFontName;
    parser.boldItalicFontName = self.boldItalicFontName;
    parser.codeFontName = self.codeFontName;
    parser.linkFontName = self.linkFontName;
    parser.topAttributes = self.topAttributes;
    parser.shouldParseLinks = self.shouldParseLinks;

    for (XNGMarkdownParserHeader header = XNGMarkdownParserHeader1; header <= XNGMarkdownParserHeader6; ++header) {
        [parser setFont:[self fontForHeader:header] forHeader:header];
    }
    return parser;
}

- (id)keyForHeader:(XNGMarkdownParserHeader)header {
    return @(header);
}

- (void)setFont:(UINSFont *)font forHeader:(XNGMarkdownParserHeader)header {
    _headerFonts[[self keyForHeader:header]] = font;
}

- (UINSFont *)fontForHeader:(XNGMarkdownParserHeader)header {
    return _headerFonts[[self keyForHeader:header]];
}

- (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)string {
    _links = [NSMutableArray array];
    _bulletStarts = [NSMutableArray array];
    _accum = [[NSMutableAttributedString alloc] init];

    const char *cstr = [string UTF8String];
    markdownin = fmemopen((void *)cstr, [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], "r");

    yyscan_t scanner;

    xng_markdownlex_init(&scanner);
    xng_markdownset_extra((__bridge void *)(self), scanner);
    xng_markdownset_in(markdownin, scanner);
    xng_markdownlex(scanner);
    xng_markdownlex_destroy(scanner);

    fclose(markdownin);

    if (_bulletStarts.count > 0) {
        // Treat nested bullet points as flat ones...

        // Finish off the previous dash and start a new one.
        NSInteger lastBulletStart = [[_bulletStarts lastObject] intValue];
        [_bulletStarts removeLastObject];

        [_accum addAttributes:[self paragraphStyle]
                        range:NSMakeRange(lastBulletStart, _accum.length - lastBulletStart)];
    }

#if TARGET_OS_MAC
    const BOOL shouldAddLinks = YES;
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    const BOOL shouldAddLinks = (NSLinkAttributeName != nil);
#endif

    if (self.shouldParseLinks && shouldAddLinks) {
        [self addLinksToAttributedString];
    }

    return [_accum copy];
}

- (void)addLinksToAttributedString {
#if TARGET_OS_MAC || __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    UINSFont *linkFont = [UINSFont fontWithName:self.linkFontName
                                           size:self.paragraphFont.pointSize];
    for (XNGMarkdownLink *link in _links) {
        NSURL *url = [NSURL URLWithString:link.url];
        if (url != nil) {
            [_accum addAttributes:@{NSLinkAttributeName: url,
                                    NSFontAttributeName: linkFont}
                            range:link.range];
        }
    }
#endif
}

- (NSArray *)links {
    return [_links copy];
}

- (NSDictionary *)paragraphStyle {
    CGFloat paragraphSpacing = 0.0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat firstLineHeadIndent = 15.0;
    CGFloat headIndent = 30.0;

    CGFloat firstTabStop = 35.0; // width of your indent
    CGFloat lineSpacing = 0.45;

#ifdef TARGET_OS_IPHONE
    NSTextAlignment alignment = NSTextAlignmentLeft;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.paragraphSpacing = paragraphSpacing;
    style.paragraphSpacingBefore = paragraphSpacingBefore;
    style.firstLineHeadIndent = firstLineHeadIndent;
    style.headIndent = headIndent;
    style.lineSpacing = lineSpacing;
    style.alignment = alignment;
    style.tabStops = @[[[NSTextTab alloc] initWithTextAlignment:alignment location:firstTabStop options:@{}]];

    return @{NSParagraphStyleAttributeName: style};
#else
    CTTextAlignment alignment = kCTLeftTextAlignment;

    CTTextTabRef tabArray[] = {CTTextTabCreate(0, firstTabStop, NULL)};

    CFArrayRef tabStops = CFArrayCreate(kCFAllocatorDefault, (const void **)tabArray, 1, &kCFTypeArrayCallBacks);
    CFRelease(tabArray[0]);

    CTParagraphStyleSetting altSettings[] =
    {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineHeadIndent},
        {kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent},
        {kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore}
    };

    CTParagraphStyleRef style;
    style = CTParagraphStyleCreate(altSettings, sizeof(altSettings) / sizeof(CTParagraphStyleSetting));

    if (style == NULL) {
        NSLog(@"*** Unable To Create CTParagraphStyle in apply paragraph formatting");
        return nil;
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)style, (NSString *)kCTParagraphStyleAttributeName, nil];
#endif
}

- (UINSFont *)topFont {
    if (nil == _topFont) {
        return self.paragraphFont;
    } else {
        return _topFont;
    }
}

- (NSDictionary *)attributesForFontWithName:(NSString *)fontName {
    return @{NSFontAttributeName: [UINSFont fontWithName:fontName size:self.topFont.pointSize]};
}

- (NSDictionary *)attributesForFont:(UINSFont *)font {
    return @{NSFontAttributeName: font};
}

- (void)recurseOnString:(NSString *)string withFont:(UINSFont *)font {
    [self recurseOnString:string withFont:font withTextColor:nil];
}

- (void)recurseOnString:(NSString *)string withFont:(UINSFont *)font withTextColor:(UIColor *)textColor {
    XNGMarkdownParser *recursiveParser = [self copy];
    recursiveParser->_topFont = font;
    
    NSAttributedString *recursedString =[recursiveParser attributedStringFromMarkdownString:string];
    NSMutableAttributedString *mutableRecursiveString = [[NSMutableAttributedString alloc] initWithAttributedString:recursedString];
    if (textColor) {
        [mutableRecursiveString addAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor}
                                        range:NSMakeRange(0, recursedString.length)];
    } else {
        [mutableRecursiveString addAttributes:@{NSFontAttributeName : font}
                                        range:NSMakeRange(0, recursedString.length)];
    }
    [_accum appendAttributedString:mutableRecursiveString];
}

- (void)consumeToken:(XNGMarkdownParserCode)token text:(char *)text {
    NSString *textAsString = [[NSString alloc] initWithCString:text encoding:NSUTF8StringEncoding];

    NSMutableDictionary *attributes;
    if (self.topAttributes != nil) {
        attributes = [NSMutableDictionary dictionaryWithDictionary:self.topAttributes];
    } else {
        attributes = [NSMutableDictionary dictionary];
    }
    [attributes addEntriesFromDictionary:[self attributesForFont:self.topFont]];

    XNGMarkdownParserCode codeToken = token;
    switch (codeToken) {
        case MARKDOWN_BULLETSTART: {
            NSInteger numberOfDashes = [textAsString rangeOfString:@" "].location;
            if (_bulletStarts.count > 0 && _bulletStarts.count <= numberOfDashes) {
                // Treat nested bullet points as flat ones...

                // Finish off the previous dash and start a new one.
                NSInteger lastBulletStart = [[_bulletStarts lastObject] intValue];
                [_bulletStarts removeLastObject];

                [_accum addAttributes:[self paragraphStyle]
                                range:NSMakeRange(lastBulletStart, _accum.length - lastBulletStart)];
            }

            [_bulletStarts addObject:@(_accum.length)];
            textAsString = @"•\t";
            break;
        }

        case MARKDOWN_EM: { // * *
            textAsString = [textAsString substringWithRange:NSMakeRange(1, textAsString.length - 2)];
            [attributes addEntriesFromDictionary:[self attributesForFontWithName:self.italicFontName]];
            break;
        }
        case MARKDOWN_STRONG: { // ** **
            textAsString = [textAsString substringWithRange:NSMakeRange(2, textAsString.length - 4)];
            [attributes addEntriesFromDictionary:[self attributesForFontWithName:self.boldFontName]];
            break;
        }
        case MARKDOWN_STRONGEM: { // *** ***
            textAsString = [textAsString substringWithRange:NSMakeRange(3, textAsString.length - 6)];
            [attributes addEntriesFromDictionary:[self attributesForFontWithName:self.boldItalicFontName]];
            break;
        }
        case MARKDOWN_STRIKETHROUGH: { // ~~ ~~
            textAsString = [textAsString substringWithRange:NSMakeRange(2, textAsString.length - 4)];
            [attributes addEntriesFromDictionary:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)}];
            break;
        }
        case MARKDOWN_CODESPAN: { // ` `
            textAsString = [textAsString substringWithRange:NSMakeRange(1, textAsString.length - 2)];
            [attributes addEntriesFromDictionary:[self attributesForFontWithName:self.codeFontName]];
            break;
        }
        case MARKDOWN_HEADER: { // ####
            NSRange rangeOfNonHash = [textAsString rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"#"] invertedSet]];
            if (rangeOfNonHash.length > 0) {
                textAsString = [[textAsString substringFromIndex:rangeOfNonHash.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                XNGMarkdownParserHeader header = (XNGMarkdownParserHeader)(rangeOfNonHash.location - 1);
                [self recurseOnString:textAsString withFont:[self fontForHeader:header] withTextColor:self.headerTextColor];

                // We already appended the recursive parser's results in recurseOnString.
                textAsString = nil;
            }
            break;
        }
        case MARKDOWN_MULTILINEHEADER: {
            textAsString = [textAsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *components = [textAsString componentsSeparatedByString:@"\n"];
            textAsString = [components objectAtIndex:0];
            UINSFont *font = nil;
            if ([[components objectAtIndex:1] rangeOfString:@"="].length > 0) {
                font = [self fontForHeader:XNGMarkdownParserHeader1];
            } else if ([[components objectAtIndex:1] rangeOfString:@"-"].length > 0) {
                font = [self fontForHeader:XNGMarkdownParserHeader2];
            }
            
            [self recurseOnString:textAsString withFont:font withTextColor:self.headerTextColor];

            // We already appended the recursive parser's results in recurseOnString.
            textAsString = nil;
            break;
        }
        case MARKDOWN_PARAGRAPH: {
            textAsString = @"\n\n";

            if (_bulletStarts.count > 0) {
                // Treat nested bullet points as flat ones...

                // Finish off the previous dash and start a new one.
                NSInteger lastBulletStart = [[_bulletStarts lastObject] intValue];
                [_bulletStarts removeLastObject];

                [_accum addAttributes:[self paragraphStyle]
                                range:NSMakeRange(lastBulletStart, _accum.length - lastBulletStart)];
            }
            break;
        }
        case MARKDOWN_NEWLINE: {
            textAsString = @"";
            break;
        }
        case MARKDOWN_EMAIL: {
            XNGMarkdownLink *link = [[XNGMarkdownLink alloc] init];
            link.url = [@"mailto:" stringByAppendingString:textAsString];
            link.range = NSMakeRange(_accum.length, textAsString.length);
            [_links addObject:link];
            break;
        }
        case MARKDOWN_URL: {
            XNGMarkdownLink *link = [[XNGMarkdownLink alloc] init];
            link.url = textAsString;
            link.range = NSMakeRange(_accum.length, textAsString.length);
            [_links addObject:link];
            break;
        }
        case MARKDOWN_HREF: { // [Title] (url "tooltip")
            textAsString = [textAsString stringByReplacingOccurrencesOfString:@"\\[" withString:@"["];
            textAsString = [textAsString stringByReplacingOccurrencesOfString:@"\\]" withString:@"]"];

            NSRange rangeOfFirstOpenBracket = [textAsString rangeOfString:@"[" options:0];
            NSRange rangeOfLastCloseBracket = [textAsString rangeOfString:@"]" options:NSBackwardsSearch];
            NSRange rangeOfLastOpenParenthesis = [textAsString rangeOfString:@"(" options:NSBackwardsSearch];
            NSRange rangeOfLastCloseParenthesis = [textAsString rangeOfString:@")" options:NSBackwardsSearch];

            NSRange linkTitleRange = NSMakeRange(rangeOfFirstOpenBracket.location + 1,
                                                 rangeOfLastCloseBracket.location - rangeOfFirstOpenBracket.location - 1);
            NSRange linkURLRange = NSMakeRange(rangeOfLastOpenParenthesis.location + 1,
                                               rangeOfLastCloseParenthesis.location - rangeOfLastOpenParenthesis.location - 1);

            if (linkTitleRange.location != NSNotFound && linkURLRange.location != NSNotFound) {
                XNGMarkdownLink *link = [[XNGMarkdownLink alloc] init];

                link.url = [textAsString substringWithRange:linkURLRange];
                link.range = NSMakeRange(_accum.length, linkTitleRange.length);

                [_links addObject:link];
                textAsString = [textAsString substringWithRange:linkTitleRange];
            }
            break;
        }
        default: {
            break;
        }
    }

    if (textAsString != nil) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:textAsString
                                                                               attributes:attributes];
        [_accum appendAttributedString:attributedString];
    }
}

@end

int xng_markdown_consume(char *text, XNGMarkdownParserCode token, yyscan_t scanner) {
    XNGMarkdownParser *string = (__bridge XNGMarkdownParser *)(xng_markdownget_extra(scanner));
    [string consumeToken:token text:text];
    return 0;
}
