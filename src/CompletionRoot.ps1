. $PSScriptRoot/GitCommands.ps1
. $PSScriptRoot/GitStatics.ps1
. $PSScriptRoot/CompletionUtil.ps1
. $PSScriptRoot/CompleteConfig.ps1
. $PSScriptRoot/CompleteSubCommands.ps1

function WriteLog {
    param([Parameter(Position = 0)]$Object)
    
    if ($env:GitCompletionDubugPath) {
        $Object >> $env:GitCompletionDubugPath
    }
}

# __git_main
function Complete-Git-Ast {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,
        [int]
        $CursorPosition
    )

    if ($env:GitCompletionDubugPath -and (-not $env:GitCompletionDubugKeep)) {
        $null > $env:GitCompletionDubugPath
    }

    $CommandAst = $CommandAst
    $script:CursorPosition = $CursorPosition
    $script:Words = ($CommandAst.CommandElements | Select-Object -ExpandProperty Extent | Select-Object -ExpandProperty Text)

    $cw = $CommandAst.CommandElements.Count
    $pr = $script:Words[$script:Words.Count - 1]
    $cr = ''

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $extent = $CommandAst.CommandElements[$i].Extent

        if ($CursorPosition -lt $extent.StartOffset) {
            # The cursor is within whitespace between the previous and current words.
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            $cw = $i
            break
        }
        elseif ($CursorPosition -le $extent.EndOffset) {
            $cr = $extent.Text
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            $cw = $i
            break
        }
    }

    $script:WordPosition = $cw
    $script:CurrentWord = $cr
    $script:PreviousWord = $pr

    WriteLog "CommandAst=$CommandAst"
    Complete-Git `
        -CursorPosition $CursorPosition `
        -Words $Words `
        -WordPosition $WordPosition `
        -CurrentWord $CurrentWord `
        -PreviousWord $PreviousWord
}

$gitGlobalOptions = @(
    (
        New-CommandOption -Short '-v' -Long '--version' `
            -Desc 'Prints the Git suite version.'
    ),
    (
        New-CommandOption -Short '-h' -Long '--help' `
            -Desc 'Prints the helps. If --all is given then all available commands are printed.'
    ),
    (
        New-CommandOption -Short '-C' `
            -Value '<path>' `
            -Desc 'Run as if git was started in <path> instead of the current working directory.' 
    ),
    (
        New-CommandOption -Short '-c' `
            -Value '<name>=<value>' `
            -Desc 'Pass a configuration parameter to the command.'
    ),
    (
        New-CommandOption -Long '--config-env' `
            -Value '<name>=<envvar>' `
            -Desc 'Like -c <name>=<value>, give configuration variable <name> a value, where <envvar> is the name of an environment variable from which to retrieve the value.'
    ),
    (
        New-CommandOption -Long '--exec-path' `
            -Value '<path>' `
            -Desc 'Path to wherever your core Git programs are installed.'
    ),
    (
        New-CommandOption -Long '--html-path' `
            -Desc "Print the path, without trailing slash, where Git’s HTML documentation is installed and exit."
    ),
    (
        New-CommandOption -Long '--man-path' `
            -Desc 'Print the manpath for the man pages for this version of Git and exit.'
    ),
    (
        New-CommandOption -Long '--info-path' `
            -Desc 'Print the path where the Info files documenting this version of Git are installed and exit.'
    ),
    (
        New-CommandOption -Short '-p' -Long '--paginate' `
            -Desc 'Pipe all output into less (or if set, $PAGER) if standard output is a terminal.'
    ),
    (
        New-CommandOption -Short '-P' -Long '--no-pager' `
            -Desc 'Do not pipe Git output into a pager.'
    ),
    (
        New-CommandOption -Long '--git-dir' `
            -Desc 'Set the path to the repository (".git" directory).'
    ),
    (
        New-CommandOption -Long '--work-tree' `
            -Value '<path>' `
            -Desc 'Set the path to the working tree.'
    ),
    (
        New-CommandOption -Long '--namespace' `
            -Value '<path>' `
            -Desc 'Set the Git namespace.'
    ),
    (
        New-CommandOption -Long '--bare' `
            -Desc 'Treat the repository as a bare repository.'
    ),
    (
        New-CommandOption -Long '--no-replace-objects' `
            -Desc 'Do not use replacement refs to replace Git objects.'
    ),
    (
        New-CommandOption -Long '--no-lazy-fetch' `
            -Desc 'Do not fetch missing objects from the promisor remote on demand.'
    ),
    (
        New-CommandOption -Long '--literal-pathspecs' `
            -Desc 'Treat pathspecs literally (i.e. no globbing, no pathspec magic).'
    ),
    (
        New-CommandOption -Long '--glob-pathspecs' `
            -Desc 'Add "glob" magic to all pathspec.'
    ),
    (
        New-CommandOption -Long '--noglob-pathspecs' `
            -Desc 'Add "literal" magic to all pathspec.'
    ),
    (
        New-CommandOption -Long '--icase-pathspecs' `
            -Desc 'Add "icase" magic to all pathspec.'
    ),
    (
        New-CommandOption -Long '--no-optional-locks' `
            -Desc 'Do not perform optional operations that require locks.'
    ),
    (
        New-CommandOption -Long '--list-cmds' `
            -Value '<group>[,<group>…​]' `
            -Desc 'List commands by group.'
    ),
    (
        New-CommandOption -Long '--no-replace-objects' `
            -Desc 'List commands by group.'
    ),
    (
        New-CommandOption  -Long '--attr-source' `
            -Desc 'Read gitattributes from <tree-ish> instead of the worktree.' `
            -Value '<tree-ish>'
    )
)

$gitSubCommandDescriptions = @{
    'clone'   = 'Clone a repository into a new directory';
    'init'    = 'Create an empty Git repository or reinitialize an existing one';
    'add'     = 'Add file contents to the index';
    'mv'      = 'Move or rename a file, a directory, or a symlink';
    'restore' = 'Restore working tree files';
    'rm'      = 'Remove files from the working tree and from the index';
    'bisect'  = 'Use binary search to find the commit that introduced a bug';
    'diff'    = 'Show changes between commits, commit and working tree, etc';
    'grep'    = 'Print lines matching a pattern';
    'log'     = 'Show commit logs';
    'show'    = 'Show various types of objects';
    'status'  = 'Show the working tree status';
    'branch'  = 'List, create, or delete branches';
    'commit'  = 'Record changes to the repository';
    'merge'   = 'Join two or more development histories together';
    'rebase'  = 'Reapply commits on top of another base tip';
    'reset'   = 'Reset current HEAD to the specified state';
    'switch'  = 'Switch branches';
    'tag'     = 'Create, list, delete or verify a tag object signed with GPG';
    'fetch'   = 'Download objects and refs from another repository';
    'pull'    = 'Fetch from and integrate with another repository or a local branch';
    'push'    = 'Update remote refs along with associated objects';
}

function Complete-Git {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [int][Parameter(Mandatory)]$CursorPosition,
        [string[]][AllowEmptyCollection()][AllowEmptyString()][Parameter(Mandatory)]$Words,
        [int][Parameter(Mandatory)]$WordPosition,
        [string][AllowEmptyString()][Parameter(Mandatory)]$CurrentWord,
        [string][AllowEmptyString()][Parameter(Mandatory)]$PreviousWord
    )
    
    WriteLog "CursorPosition=$CursorPosition"
    WriteLog "Words=$Words"
    WriteLog "WordPosition=$WordPosition"
    WriteLog "CurrentWord=$CurrentWord"
    WriteLog "PreviousWord=$PreviousWord"

    $script:CursorPosition = $CursorPosition
    $script:Words = $Words
    $script:gitCArgs = $gitCArgs
    $script:command = $command
    $script:commandIndex = $commandIndex
    $script:WordPosition = $WordPosition
    $script:CurrentWord = $CurrentWord
    $script:PreviousWord = $PreviousWord
    
    $script:__git_repo_path = $null
    $script:gitDir = $null
    $script:gitCArgs = @()
    $script:command = ''
    $script:commandIndex = 0

    :globalflag for ($i = 1; $i -lt $script:WordPosition; $i++) {
        $s = $script:Words[$i]
        switch -Wildcard -CaseSensitive ($s) {
            '--git-dir=*' {
                $script:gitDir = [System.IO.DirectoryInfo]::new($s.Substring('--git-dir='.Length))
                continue
            }
            '--git-dir' {
                if (++$i -lt $script:Words.Count) {
                    $script:gitDir = [System.IO.DirectoryInfo]::new($script:Words[$i])
                }
                continue
            }
            '--bare' {
                $script:gitDir = [System.IO.DirectoryInfo]::new('.')
                continue
            }
            '--help' {
                $script:command = 'help'
                break globalflag
            }
            { $_ -cin @('-c', '--work-tree', '--namespace') } {
                ++$i
                continue
            }
            '-C' {
                $script:gitCArgs += @('-C', $script:Words[++$i])
                continue
            }
            '-*' {
                continue
            }
            default {
                $script:command = $s
                $script:commandIndex = $i
                break globalflag
            }
        }
    }
    WriteLog "gitDir=$gitDir"
    WriteLog "gitCArgs=$gitCArgs"
    WriteLog "command=$command"
    WriteLog "commandIndex=$commandIndex"

    if ($command) {
        return CompleteSubCommands
    }

    switch -Wildcard -CaseSensitive ($PreviousWord) {
        { $_ -cin @('-C', '--work-tree', '--git-dir') } {
            # these need a path argument
            return
        }
        '-c' {
            completeConfigVariableNameAndValue -Current $CurrentWord
            return
        }
        '--namespace' {
            # we don't support completing these options' arguments
            return
        }
    }

    switch -Wildcard ($CurrentWord) {
        '--*' {
            $gitGlobalOptions | ForEach-Object { $_.ToLongCompletion($CurrentWord) } | Where-Object { $_ }
            return
        }
        '-*' {
            if ($CurrentWord -eq '-') {
                $gitGlobalOptions | ForEach-Object { $_.ToShortCompletion() } | Where-Object { $_ }
            }
            return
        }
    }

    $descriptions = $gitSubCommandDescriptions.Clone()
    foreach ($a in (gitListAliases)) {
        $descriptions[$a.Name] = "[alias] $($a.Value)"
    }

    $commands = (gitAllCommands builtins list-mainporcelain others nohelpers alias list-complete config)
    $commands -clike "$script:CurrentWord*" | Sort-Object -Unique | ForEach-Object {
        $desc = $descriptions[$_]
        if (-not $desc) {
            $desc = $_
        }
        [System.Management.Automation.CompletionResult]::new(
            "$_",
            "$_",
            "Text",
            $desc
        )
    }
}