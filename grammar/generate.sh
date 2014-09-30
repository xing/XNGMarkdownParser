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

flex --prefix=xng_markdown --nounput markdown.grammar

cat MarkdownTokenizerPrefix > XNGMarkdownTokenizer.cpp
cat lex.xng_markdown.c >> XNGMarkdownTokenizer.cpp

rm lex.xng_markdown.c

mv XNGMarkdownTokenizer.cpp ../src/XNGMarkdownTokenizer.m
cp XNGMarkdownTokens.cpp ../src/XNGMarkdownTokens.m
cp XNGMarkdownTokens.h ../src/XNGMarkdownTokens.h
