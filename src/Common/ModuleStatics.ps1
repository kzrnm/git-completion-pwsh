# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
[string]$script:DirectorySeparatorChars = ((@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) | Sort-Object -Unique) -join '')
[string]$script:DirectorySeparatorCharsRegex = "$($DirectorySeparatorChars.Replace('\', '\\'))"