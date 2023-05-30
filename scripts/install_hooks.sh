#!/bin/sh

# Make .git_hooks folder as hooks source for git
git config core.hooksPath .git_hooks/

# install commitlint and @commitlint/config-conventional globally
npm install -g commitlint @commitlint/config-conventional
