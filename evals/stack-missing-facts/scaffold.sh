#!/bin/bash
# Fixture "empty": a new git repository with one empty commit.
set -e
git init -q -b main
git -c user.name=dev -c user.email=dev@example.com commit -q --allow-empty -m "chore: start"
