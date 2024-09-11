# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
Get-ChildItem -Recurse "$PSScriptRoot/../src" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }
. "$PSScriptRoot/../testtools/ConvertCompletion.ps1"
