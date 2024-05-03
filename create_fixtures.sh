#! /bin/sh

rm -rf Tests/swift-conventional-commit-parserTests/Fixtures

mkdir -p Tests/swift-conventional-commit-parserTests/Fixtures
cd Tests/swift-conventional-commit-parserTests/Fixtures

git config --global init.defaultBranch main

mkdir -p GitRepoNoCommits
cd GitRepoNoCommits
git init
git checkout -b main

cd ..

mkdir -p GitRepoChoreOnMainFeatOnBranch
cd GitRepoChoreOnMainFeatOnBranch
git init
touch "README.md"
git add "README.md"
git commit -m "chore: Add README.md"
git checkout -b "feature/myAwesomeFeature"
touch "AwesomeCode.swift"
git add "AwesomeCode.swift"
git commit -m "feat: My awesome feature"

cd ..

mkdir -p GitRepoChoreOnMainNoFormattedCommitOnBranch
cd GitRepoChoreOnMainNoFormattedCommitOnBranch
git init
touch "README.md"
git add "README.md"
git commit -m "chore: Add README.md"
git checkout -b "feature/myAwesomeFeature"
touch "AwesomeCodeWithoutFormattedCommit.swift"
git add "AwesomeCodeWithoutFormattedCommit.swift"
git commit -m "wip"