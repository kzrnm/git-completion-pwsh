@(git diff-index HEAD --name-only --relative tests) -like '*.ps1'
@(git ls-files tests -o --exclude-standard) -like '*.ps1'