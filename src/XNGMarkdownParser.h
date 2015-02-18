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

#import <Foundation/Foundation.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#define UINSFont UIFont
#else
#import <AppKit/AppKit.h>
#define UINSFont NSFont
#endif

typedef NS_ENUM (NSUInteger, XNGMarkdownParserHeader) {
    XNGMarkdownParserHeader1,
    XNGMarkdownParserHeader2,
    XNGMarkdownParserHeader3,
    XNGMarkdownParserHeader4,
    XNGMarkdownParserHeader5,
    XNGMarkdownParserHeader6,
};

@interface XNGMarkdownLink : NSObject
@property (nonatomic, readonly, strong) NSString *url;
@property (nonatomic, readonly, assign) NSRange range;
@end

/**
 * The NSAttributedStringMarkdownParser class parses a given markdown string into an
 * NSAttributedString.
 *
 * @ingroup NimbusMarkdown
 */
@interface XNGMarkdownParser : NSObject <NSCopying>

- (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)string;
- (NSArray *)links; // Array of NSAttributedStringMarkdownLink

@property (nonatomic, strong) UINSFont *paragraphFont; // Default: systemFontOfSize:12
@property (nonatomic, copy) NSString *boldFontName; // Default: boldSystemFont
@property (nonatomic, copy) NSString *italicFontName; // Default: Helvetica-Oblique
@property (nonatomic, copy) NSString *boldItalicFontName; // Default: Helvetica-BoldOblique
@property (nonatomic, copy) NSString *codeFontName; // Default: Courier
@property (nonatomic, copy) NSString *linkFontName; // Default: paragraphFont
@property (nonatomic, assign) BOOL shouldParseLinks; // Default: YES

// common attributes that affect the whole string, can be overriden by the upper attributes
@property (nonatomic, strong) NSDictionary *topAttributes;  // default: nil (do nothing)

- (void)setFont:(UINSFont *)font forHeader:(XNGMarkdownParserHeader)header;
- (UINSFont *)fontForHeader:(XNGMarkdownParserHeader)header;

@end
