#!/bin/bash
#
# Copyright 2011-2014 NimbusKit
# Copyright 2014 XING AG
#
# Builds a Markdown tokenizer using flex - http://flex.sourceforge.net/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

GRAMMAR_DIR="$SRCROOT/../grammar"
SOURCE_DIR="$SRCROOT/../src"
LEX_OUTPUT="$GRAMMAR_DIR/lex.xng_markdown.c"
NEW_TOKENIZER="$GRAMMAR_DIR/XNGMarkdownTokenizer.cpp"
SRC_TOKENIZER="$SOURCE_DIR/XNGMarkdownTokenizer.m"

flex --prefix=xng_markdown --nounput --outfile=$LEX_OUTPUT $GRAMMAR_DIR/markdown.grammar

cat $GRAMMAR_DIR/MarkdownTokenizerPrefix > $NEW_TOKENIZER
cat $LEX_OUTPUT >> $NEW_TOKENIZER

rm $LEX_OUTPUT

#move files only if the newly generated file is different
if diff $NEW_TOKENIZER $SRC_TOKENIZER >/dev/null ; then
  echo "Files are same, not copying"
else
  echo "Files differ, copy tokenizer to src"
  mv $NEW_TOKENIZER $SRC_TOKENIZER
  cp $GRAMMAR_DIR/XNGMarkdownTokens.cpp $SOURCE_DIR/XNGMarkdownTokens.m
  cp $GRAMMAR_DIR/XNGMarkdownTokens.h $SOURCE_DIR/XNGMarkdownTokens.h
fi

