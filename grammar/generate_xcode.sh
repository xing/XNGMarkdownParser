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

echo "srcroot: $SRCROOT"

GRAMMAR_DIR="$SRCROOT/../grammar"
SOURCE_DIR="$SRCROOT/../src"

echo "output: $GRAMMAR_DIR/markdown.grammar"


flex --prefix=xng_markdown --nounput --outfile=$GRAMMAR_DIR/lex.xng_markdown.c $GRAMMAR_DIR/markdown.grammar

cat $GRAMMAR_DIR/MarkdownTokenizerPrefix > $GRAMMAR_DIR/XNGMarkdownTokenizer.cpp
cat $GRAMMAR_DIR/lex.xng_markdown.c >> $GRAMMAR_DIR/XNGMarkdownTokenizer.cpp

rm $GRAMMAR_DIR/lex.xng_markdown.c

mv $GRAMMAR_DIR/XNGMarkdownTokenizer.cpp $SOURCE_DIR/XNGMarkdownTokenizer.m
cp $GRAMMAR_DIR/XNGMarkdownTokens.cpp $SOURCE_DIR/XNGMarkdownTokens.m
cp $GRAMMAR_DIR/XNGMarkdownTokens.h $SOURCE_DIR/XNGMarkdownTokens.h
