enum IndexFilesOptions {
    Cached
    Updated
    Modified
    Untracked
    Ignored
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

    $Current = $Current.Replace('\', '\\')
    $lsFilesOptions = switch ($Options) {
        Cached { '--cached' }
        Updated { '--others', '--modified', '--no-empty-directory' } 
        Modified { '--modified' }
        Untracked { '--others', '--directory' }
        Ignored {
            $a = __git @BaseDirOpts ls-files -z --others --directory '--' $Pattern
            $b = __git @BaseDirOpts ls-files -z --exclude-standard --others --directory '--' $Pattern
            $a = @("$a".Split("`0"))
            $b = @("$b".Split("`0"))

            $files = Compare-Object $a $b
            return $files | ForEach-Object InputObject | ForEach-Object {
                if ($_) {
                    "$BaseDir$_"
                }
            } | Sort-Object
        }
        Committable {
            $results = __git @BaseDirOpts diff-index -z --name-only --relative HEAD '--' $Pattern
        }
    }

    if ($lsFilesOptions) {
        $lsFilesOptions = @($lsFilesOptions)
        $results = __git @BaseDirOpts ls-files -z --exclude-standard @lsFilesOptions '--' $Pattern
    }

    foreach ($file in "$results".Split("`0")) {
        if ($file) {
            "$BaseDir$file"
        }
    }
}
