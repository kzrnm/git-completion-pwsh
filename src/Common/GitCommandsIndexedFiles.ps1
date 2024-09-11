# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
enum IndexFilesOptions {
    None
    Cached
    CachedAndUntracked
    Updated
    Modified
    Untracked
    Ignored
    All
    AllWithIgnored
    Committable
}

# __git_index_files
# __git_ls_files_helper
function gitIndexFiles {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Current,
        [string]
        $BaseDir = '',
        [Parameter(Mandatory)]
        [IndexFilesOptions]
        $Options
    )

    $BaseDirOpts = if ($BaseDir) {
        @('-C', $BaseDir)
    }
    else {
        @()
    }

    $Pattern = if ($Current) {
        "$Current*"
    }
    else {
        '.'
    }

    $results = $null
    $Current = $Current.Replace('\', '\\')
    $lsFilesOptions = switch ($Options) {
        None { @() }
        Cached { '--cached' }
        CachedAndUntracked { '--cached', '--others', '--directory' }
        Updated { '--others', '--modified', '--no-empty-directory' }
        Modified { '--modified' }
        Untracked { '--others', '--directory' }
        Ignored { '--ignored', '--others', '--exclude=*' }
        All { '--cached', '--directory', '--no-empty-directory', '--others' }
        AllWithIgnored { '--cached', '--directory', '--no-empty-directory', '--others', '--ignored', '--exclude=*' }
        Committable {
            $results = __git @BaseDirOpts diff-index -z --name-only --relative HEAD '--' $Pattern
        }
    }

    if ($null -eq $results) {
        $lsFilesOptions = @($lsFilesOptions)
        $results = __git @BaseDirOpts ls-files -z --exclude-standard @lsFilesOptions '--' $Pattern
    }

    foreach ($file in "$results".Split("`0")) {
        if ($file) {
            "$BaseDir$file"
        }
    }
}
