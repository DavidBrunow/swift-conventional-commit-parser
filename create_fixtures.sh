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

mkdir -p GitRepoChoreOnMainFeatOnBranchTaggedVersion1
cd GitRepoChoreOnMainFeatOnBranchTaggedVersion1
git init
touch "AwesomeCodeForVersion1.swift"
git add "AwesomeCodeForVersion1.swift"
git commit -m "feat!: Awesome code for version 1"
git tag 1.0.0
touch "README.md"
git add "README.md"
git commit -m "chore: Add README.md"
git checkout -b "feature/myAwesomeFeature"
touch "AwesomeCodeTaggedVersion1.swift"
git add "AwesomeCodeTaggedVersion1.swift"
git commit -m "feat: My awesome feature"

cd ..

mkdir -p GitRepoChoreOnMainFeatOnBranchTaggedVersion1Release
cd GitRepoChoreOnMainFeatOnBranchTaggedVersion1Release
git init
touch "AwesomeCodeForVersion1.md"
git add "AwesomeCodeForVersion1.md"
git commit -m "feat!: Awesome code for version 1"
git tag 1.0.0
touch "README.md"
git add "README.md"
git commit -m "chore: Add README.md"
git checkout -b "feature/myAwesomeFeature"
touch "AwesomeCodeTaggedVersion1.md"
git add "AwesomeCodeTaggedVersion1.md"
git commit -m "feat: My awesome feature"
git checkout main
git merge "feature/myAwesomeFeature"

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

cd ..

mkdir -p GitRepoChoreOnMainNoFormattedCommitOnBranchTaggedVersion1
cd GitRepoChoreOnMainNoFormattedCommitOnBranchTaggedVersion1
git init
touch "AnotherAwesomeCodeForVersion1.swift"
git add "AnotherAwesomeCodeForVersion1.swift"
git commit -m "feat!: Awesome code for version 1"
git tag 1.0.0
touch "README.md"
git add "README.md"
git commit -m "chore: Add README.md"
git checkout -b "feature/myAwesomeFeature"
touch "AwesomeCodeWithoutFormattedCommitTaggedVersion1.swift"
git add "AwesomeCodeWithoutFormattedCommitTaggedVersion1.swift"
git commit -m "wip"

cd ..
mkdir -p GitRepoHotfixNoFormattedCommitOnBranch
cd GitRepoHotfixNoFormattedCommitOnBranch
git init
touch "v1.md"
git add "v1.md"
git commit -m "feat!: v1"
git tag 1.0.0
touch "v2.md"
git add "v2.md"
git commit -m "feat!: v2"
git tag 2.0.0
git checkout -b release/1.1 1.0.0
git checkout -b hotfix
touch "hotfix.md"
git add "hotfix.md"
git commit -m "wip"

cd ..

mkdir -p GitRepoHotfixFormattedCommitOnBranch
cd GitRepoHotfixFormattedCommitOnBranch
git init
touch "v1.md"
git add "v1.md"
git commit -m "feat!: v1"
git tag 1.0.0
touch "v1.1.md"
git add "v1.1.md"
git commit -m "feat: v1.1"
git tag 1.1.0
touch "v1.2.md"
git add "v1.2.md"
git commit -m "feat: v1.2"
git tag 1.2.0
touch "v2.md"
git add "v2.md"
git commit -m "feat!: v2"
git tag 2.0.0
git checkout -b release/1.1.1 1.1.0
git checkout -b hotfix
touch "hotfix.md"
git add "hotfix.md"
git commit -m "hotfix: Fix the thing!"

cd ..

mkdir -p GitRepoHotfixFormattedCommitOnBranchRelease
cd GitRepoHotfixFormattedCommitOnBranchRelease
git init
touch "v1.md"
git add "v1.md"
git commit -m "feat!: v1"
git tag 1.0.0
touch "v1.1.md"
git add "v1.1.md"
git commit -m "feat: v1.1"
git tag 1.1.0
touch "v1.2.md"
git add "v1.2.md"
git commit -m "feat: v1.2"
git tag 1.2.0
touch "v2.md"
git add "v2.md"
git commit -m "feat!: v2"
git tag 2.0.0
git checkout -b release/1.1.1 1.1.0
git checkout -b hotfix
touch "hotfix.md"
git add "hotfix.md"
git commit -m "hotfix: Fix the thing!"
git checkout release/1.1.1
git merge hotfix

cd ..

mkdir -p GitRepoMainBranchFeatOnBranchLastTagNotSemanticVersion
cd GitRepoMainBranchFeatOnBranchLastTagNotSemanticVersion
git init
touch "v1.1.md"
git add "v1.1.md"
git commit -m "feat: v1.1"
git tag "SomeOtherApp1.0.0"
git tag 1.1.0
git tag "SomeOtherApp1.1.0"
git checkout -b feat/myFeature
touch "v1.2.md"
git add "v1.2.md"
git commit -m "feat: v1.2"

cd ..

mkdir -p GitRepoMainBranchFeatOnBranchLastTagNotSemanticVersionRelease
cd GitRepoMainBranchFeatOnBranchLastTagNotSemanticVersionRelease
git init
touch "v1.1.md"
git add "v1.1.md"
git commit -m "feat: v1.1"
git tag "SomeOtherApp1.0.0"
git tag 1.1.0
git tag "SomeOtherApp1.1.0"
git checkout -b feat/myFeature
touch "v1.2.md"
git add "v1.2.md"
git commit -m "feat: v1.2"
git checkout main
git merge feat/myFeature