enum IndexFilesOptions {
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
        [Parameter(Mandatory)]
        [IndexFilesOptions]
        $Options
    )

    $BaseDir = ''
    if ($Current -cmatch "^(?<prefix>(\.{1,2}[$DirectorySeparatorCharsRegex]+)+)(?<path>.*?)$") {
        $BaseDir = $Matches['prefix']
        $BaseDirOpts = @('-C', $BaseDir)
        $Current = $Matches['path']
    }
    else {
        $BaseDirOpts = @()
    }

    $Current = $Current.Replace('\', '\\')
    $lsFilesOptions = switch ($Options) {
        Updated { '--others', '--modified', '--no-empty-directory' } 
        Modified { '--modified' }
        Untracked { '--others', '--directory' }
        Ignored {
            $a = __git @BaseDirOpts ls-files -z --others --directory '--' "$Current*"
            $b = __git @BaseDirOpts ls-files -z --exclude-standard --others --directory '--' "$Current*"
            $a = @("$a".Split("`0"))
            $b = @("$b".Split("`0"))

            $files = Compare-Object $a $b
            return $files | ForEach-Object InputObject | Sort-Object
        }
        Committable {
            $results = __git @BaseDirOpts diff-index -z --name-only --relative HEAD '--' "$Current*"
        }
    }

    if ($lsFilesOptions) {
        $lsFilesOptions = @($lsFilesOptions)
        $results = __git @BaseDirOpts ls-files -z --exclude-standard @lsFilesOptions '--' "$Current*"
    }

    foreach ($file in "$results".Split("`0")) {
        if ($file) {
            "$BaseDir$file"
        }
    }
}
