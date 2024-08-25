using namespace System.Management.Automation;

function Convert-GitConfigShortToLong {
    param(
        [Parameter(Position = 0, Mandatory)][string]$Short,
        [string]$Subcommand = ''
    )
    switch($Short) {
        '-f' { '--file' }
        '-z' { '--null' }
        '-t' { '--type' }
    }
}

function Get-GitConfigShortOptions {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param(
        [string]$Subcommand = ''
    )

    $shortOptions = switch ($Subcommand) {
        'list' { @('-f', '-t', '-z') }
        'get' { @('-f', '-t', '-z') }
        'set' { @('-f', '-t') }
        'unset' { @('-f') }
        'rename-section' { @('-f') }
        'remove-section' { @('-f') }
        'edit' { @('-f') }
        Default { @() }
    }
    $shortOptions | ForEach-Object {
        $long = (Convert-GitConfigShortToLong $_ -Subcommand $Subcommand)
        $desc = (Get-GitConfigOptionsDescription $long)
        if (-not $desc) {
            $desc = $_
        }
        [CompletionResult]::new(
            $_,
            $_,
            'ParameterName',
            $desc
        )
    }
    $script:__helpCompletion
}

function Get-GitConfigOptionsDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [string]$Current,
        [string]$Subcommand = ''
    )

    if ($Current.StartsWith('--no-')) {
        $positive = Get-GitConfigOptionsDescription ('--' + $Current.Substring('--no-'.Length)) -Subcommand $Subcommand
        if ($positive) {
            return "[NO] $positive"
        }
        return $null
    }

    switch ($Current) {
        '--global' { 'use global config file' }
        '--system' { 'use system config file' }
        '--local' { 'use repository config file' }
        '--worktree' { 'use per-worktree config file' }
        '--file' { 'use given config file' }
        '--blob' { 'read config from given blob object' }
        '--null' { 'terminate values with NUL byte' }
        '--name-only' { 'show variable names only' }
        '--show-origin' { 'show origin of config (file, standard input, blob, command line)' }
        '--show-scope' { 'show scope of config (worktree, local, global, system, command)' }
        '--show-names' { 'show config keys in addition to their values' }
        '--type' { 'value is given this type' }
        '--bool' { 'value is "true" or "false"' }
        '--int' { 'value is decimal number' }
        '--bool-or-int' { 'value is --bool or --int' }
        '--bool-or-str' { 'value is --bool or string' }
        '--path' { 'value is a path (file or directory name)' }
        '--expiry-date' { 'value is an expiry date' }
        '--includes' { 'respect include directives on lookup' }
        '--all' {
            switch ($Subcommand) {
                'get' { 'return all values for multi-valued config options' }
                Default { 'replace multi-valued config option with new value' }
            }
        }
        '--regexp' { 'interpret the name as a regular expression' }
        '--value' { 'show config with values matching the pattern' }
        '--fixed-value' { 'use string equality when comparing values to value pattern' }
        '--url' { 'show config matching the given URL' }
        '--default' { 'use default value when missing entry' }
        '--comment' { 'human-readable comment string (# will be prepended as needed)' }
        '--append' { 'add a new line without altering any existing values' }
    }
}

