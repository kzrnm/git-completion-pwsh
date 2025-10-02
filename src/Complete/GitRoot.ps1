using namespace System.Management.Automation;

function Complete-Git {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'String')]
        [string[]]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $Words,
        [Parameter(ParameterSetName = 'String')]
        [int]
        $CurrentIndex = -1,
        [Parameter(Mandatory, ParameterSetName = 'Ast')]
        [Language.CommandAst]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $CommandAst,
        [Parameter(Mandatory, ParameterSetName = 'Ast')]
        [int]
        $CursorPosition
    )

    if ($PSCmdlet.ParameterSetName -eq 'Ast') {
        $Words, $CurrentIndex = buildWords $CommandAst $CursorPosition
    }

    if ($CurrentIndex -lt 0) { $CurrentIndex = $Words.Length - 1 }
    return Complete-GitCommandLine ([CommandLineContext]::new($Words, $CurrentIndex))
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
        if ($this.Long -and $this.Long.StartsWith($Prefix)) {
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

function resolveAliasContext {
    [CmdletBinding()]
    [OutputType([CommandLineContext])]
    param (
        [CommandLineContext][Parameter(Position = 0, Mandatory)]$Context
    )
    # Avoid infinite loop
    for ($i = 20; $Context.Command -and $i; $i--) {
        $aliasValue = gitGetAlias $Context.Command
        if (!$aliasValue) {
            return $Context
        }
        [string[]]$resolved = gitParseShellArgs $aliasValue
        if (!$Context.ReplaceCommand($resolved)) {
            break
        }
    }
    return $Context
}

function Complete-GitCommandLine {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext][Parameter(Position = 0, Mandatory)]$Context
    )

    $Context = resolveAliasContext $Context
    try {
        Set-Variable 'Context' $Context -Scope 'Script'

        [string] $Current = $Context.CurrentWord()
        if ($Context.Command) {
            try {
                $completeSubcommandFunc = "Complete-GitSubCommand-$($Context.Command)"
                . $completeSubcommandFunc $Context
            }
            catch {
                Complete-GitSubCommandCommon $Context
            }
            return
        }

        switch -Wildcard -CaseSensitive ($Context.PreviousWord()) {
            { $_ -cin @('-C', '--work-tree', '--git-dir', '--') } {
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

        if ($Current -eq '-') {
            $gitGlobalOptions | ForEach-Object { $_.ToShortCompletion() } | Where-Object { $_ }
            return
        }
        elseif ($Current -like '--*') {
            $gitGlobalOptions | ForEach-Object { $_.ToLongCompletion($Current) } | Where-Object { $_ }
            return
        }

        $aliases = @{}
        foreach ($a in (gitListAliases)) {
            $aliases[$a.Name] = "[alias] $($a.Value)"
        }

        listCommands | Complete-List -Current $Current -DescriptionBuilder {
            $a = $aliases[$_]
            if ($a) {
                $a
            }
            else {
                Get-GitCommandDescription $_ 
            }
        } -ResultType Text  
    }
    finally {
        Remove-Variable 'Context' -Scope 'Script'
    }
}
