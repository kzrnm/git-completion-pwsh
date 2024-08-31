@(git diff-index HEAD --name-only --relative tests) -like '*.Tests.ps1'
@(git ls-files tests -o --exclude-standard) -like '*.Tests.ps1'