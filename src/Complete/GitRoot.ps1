using namespace System.Management.Automation;

function Complete-Git {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [string[]][AllowEmptyCollection()][AllowEmptyString()][Parameter(Mandatory)]$Words
    )

    return Complete-GitCommandLine ([CommandLineContext]::new($Words))
}


class CommandOption {
    [string] $Short
    [string] $Long
    [string] $Description
    [string] $Value

    CommandOption ([string]$short, [string]$long, $description, $value) {
        $this.Short = $Short
        $this.Long = $Long
        $this.Description = $Description
        $this.Value = $Value
    }

    [CompletionResult] ToLongCompletion([string]$Prefix) {
        if ($this.Long -and ($this.Long -clike "$Prefix*")) {
            return [CompletionResult]::new(
                $this.Long,
                $this.Long + "$(if($this.Value){" $($this.Value)"})",
                'ParameterName',
                "$(if($this.Description){$this.Description}else{$this.Long})"
            )
        }
        return $null
    }

    [CompletionResult] ToShortCompletion() {
        if ($this.Short) {
            return [CompletionResult]::new(
                $this.Short,
                $this.Short + "$(if($this.Value){" $($this.Value)"})",
                'ParameterName',
                "$(if($this.Description){$this.Description}else{$this.Short})"
            )
        }
        return $null
    }
}

function New-CommandOption {
    [CmdletBinding()]
    param (
        [string]$Short = '',
        [string]$Long = '',
        [string]$Desc = '',
        [string]$Value = ''
    )
    [CommandOption]::new($Short, $Long, $Desc, $Value)
}

$gitGlobalOptions = @(
    (
        New-CommandOption -Short '-v' -Long '--version' `
            -Desc 'Prints the Git suite version'
    ),
    (
        New-CommandOption -Short '-h' -Long '--help' `
            -Desc 'Prints the helps. If --all is given then all available commands are printed'
    ),
    (
        New-CommandOption -Short '-C' `
            -Value '<path>' `
            -Desc 'Run as if git was started in <path> instead of the current working directory'
    ),
    (
        New-CommandOption -Short '-c' `
            -Value '<name>=<value>' `
            -Desc 'Pass a configuration parameter to the command'
    ),
    (
        New-CommandOption -Long '--config-env' `
            -Value '<name>=<envvar>' `
            -Desc 'Like -c <name>=<value>, give configuration variable <name> a value, where <envvar> is the name of an environment variable from which to retrieve the value'
    ),
    (
        New-CommandOption -Long '--exec-path' `
            -Value '<path>' `
            -Desc 'Path to wherever your core Git programs are installed'
    ),
    (
        New-CommandOption -Long '--html-path' `
            -Desc "Print the path, without trailing slash, where Git’s HTML documentation is installed and exit"
    ),
    (
        New-CommandOption -Long '--man-path' `
            -Desc 'Print the manpath for the man pages for this version of Git and exit'
    ),
    (
        New-CommandOption -Long '--info-path' `
            -Desc 'Print the path where the Info files documenting this version of Git are installed and exit'
    ),
    (
        New-CommandOption -Short '-p' -Long '--paginate' `
            -Desc 'Pipe all output into less (or if set, $PAGER) if standard output is a terminal'
    ),
    (
        New-CommandOption -Short '-P' -Long '--no-pager' `
            -Desc 'Do not pipe Git output into a pager'
    ),
    (
        New-CommandOption -Long '--git-dir' `
            -Desc 'Set the path to the repository (".git" directory)'
    ),
    (
        New-CommandOption -Long '--work-tree' `
            -Value '<path>' `
            -Desc 'Set the path to the working tree'
    ),
    (
        New-CommandOption -Long '--namespace' `
            -Value '<path>' `
            -Desc 'Set the Git namespace'
    ),
    (
        New-CommandOption -Long '--bare' `
            -Desc 'Treat the repository as a bare repository'
    ),
    (
        New-CommandOption -Long '--no-replace-objects' `
            -Desc 'Do not use replacement refs to replace Git objects'
    ),
    (
        New-CommandOption -Long '--no-lazy-fetch' `
            -Desc 'Do not fetch missing objects from the promisor remote on demand'
    ),
    (
        New-CommandOption -Long '--literal-pathspecs' `
            -Desc 'Treat pathspecs literally (i.e. no globbing, no pathspec magic)'
    ),
    (
        New-CommandOption -Long '--glob-pathspecs' `
            -Desc 'Add "glob" magic to all pathspec'
    ),
    (
        New-CommandOption -Long '--noglob-pathspecs' `
            -Desc 'Add "literal" magic to all pathspec'
    ),
    (
        New-CommandOption -Long '--icase-pathspecs' `
            -Desc 'Add "icase" magic to all pathspec'
    ),
    (
        New-CommandOption -Long '--no-optional-locks' `
            -Desc 'Do not perform optional operations that require locks'
    ),
    (
        New-CommandOption -Long '--list-cmds' `
            -Value '<group>[,<group>…​]' `
            -Desc 'List commands by group'
    ),
    (
        New-CommandOption -Long '--no-replace-objects' `
            -Desc 'List commands by group'
    ),
    (
        New-CommandOption  -Long '--attr-source' `
            -Value '<tree-ish>' `
            -Desc 'Read gitattributes from <tree-ish> instead of the worktree'
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

function Complete-GitCommandLine {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext][Parameter(Position = 0, Mandatory)]$Context
    )

    try {
        Set-Variable 'Context' $Context -Scope 'Script'
        [string] $Current = $Context.CurrentWord()
        if ($Context.command) {

            try {
                $completeSubcommandFunc = "Complete-GitSubCommand-$($Context.command)"
                & $completeSubcommandFunc $Context
            }
            catch {
                Complete-GitSubCommandCommon $Context
            }
            return
        }

        switch -Wildcard -CaseSensitive ($Context.PreviousWord()) {
            { $_ -cin @('-C', '--work-tree', '--git-dir') } {
                # these need a path argument
                return
            }
            '-c' {
                return completeConfigOptionVariableNameAndValue -Current $Current
            }
            '--namespace' {
                # we don't support completing these options' arguments
                return
            }
        }

        switch -Wildcard ($Current) {
            '--*' {
                $gitGlobalOptions | ForEach-Object { $_.ToLongCompletion($Current) } | Where-Object { $_ }
                return
            }
            '-*' {
                if ($Current -eq '-') {
                    $gitGlobalOptions | ForEach-Object { $_.ToShortCompletion() } | Where-Object { $_ }
                }
                return
            }
        }

        $descriptions = $gitSubCommandDescriptions.Clone()
        foreach ($a in (gitListAliases)) {
            $descriptions[$a.Name] = "[alias] $($a.Value)"
        }

        listCommands | Where-Object {
            $_.StartsWith($Current)
        } | ForEach-Object {
            $desc = $descriptions[$_]
            if (-not $desc) {
                $desc = $_
            }
            [CompletionResult]::new(
                "$_",
                "$_",
                "Text",
                $desc
            )
        }
    }
    finally {
        Remove-Variable 'Context' -Scope 'Script'
    }
}
