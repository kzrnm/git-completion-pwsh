# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
@(git diff-index HEAD --name-only --relative tests) -like '*.Tests.ps1'
@(git ls-files tests -o --exclude-standard) -like '*.Tests.ps1'