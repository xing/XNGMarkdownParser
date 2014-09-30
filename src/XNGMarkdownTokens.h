//
// Copyright 2012 Jeff Verkoeyen
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

#include <stdio.h>

typedef enum {
  MARKDOWN_FIRST_TOKEN = 0x100,
  MARKDOWN_EM = MARKDOWN_FIRST_TOKEN,
  MARKDOWN_STRONG,
  MARKDOWN_STRONGEM,
  MARKDOWN_STRIKETHROUGH,
  MARKDOWN_HEADER,
  MARKDOWN_MULTILINEHEADER,
  MARKDOWN_URL,
  MARKDOWN_HREF,
  MARKDOWN_PARAGRAPH,
  MARKDOWN_NEWLINE,
  MARKDOWN_BULLETSTART,
  MARKDOWN_CODESPAN,
  MARKDOWN_PHRASE,
  MARKDOWN_WORD,
  MARKDOWN_UNKNOWN,
} XNGMarkdownParserCode;

extern const char* xng_markdownnames[];

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

extern FILE *markdownin;

int xng_markdownlex_init(yyscan_t* yyscanner);
int xng_markdownlex_destroy(yyscan_t yyscanner);
void xng_markdownset_in(FILE * in_str, yyscan_t yyscanner);

int xng_markdownlex(yyscan_t yyscanner);
int xng_markdown_consume(char* text, XNGMarkdownParserCode token, yyscan_t yyscanner);
int xng_markdownget_lineno(yyscan_t scanner);

#define MARKDOWN_EXTRA_TYPE  void*
MARKDOWN_EXTRA_TYPE xng_markdownget_extra(yyscan_t scanner);
void xng_markdownset_extra(MARKDOWN_EXTRA_TYPE arbitrary_data , yyscan_t scanner);
