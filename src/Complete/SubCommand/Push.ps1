# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-push {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Prev = $Context.PreviousWord()
    [string] $Current = $Context.CurrentWord()

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        switch ($Prev) {
            '--repo' {
                gitRemote | completeList -Current $Current -ResultType ParameterValue 
                return
            }
            '--recurse-submodules' {
                $script:gitPushRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue 
                return
            }
        }

        switch -Wildcard ($Current) {
            '--repo=*' { 
                gitRemote | completeList -Current $Current -ResultType ParameterValue -Prefix '--repo=' -RemovePrefix
                return
            }
            '--recurse-submodules=*' { 
                $script:gitPushRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue -Prefix '--recurse-submodules=' -RemovePrefix
                return
            }
            '--force-with-lease=*' {
                $c = $Current.Substring('--force-with-lease='.Length)
                if ($c.StartsWith('--')) { }
                elseif ($c -like '*:*') {
                ($left, $right) = $c -split ":", 2
                    gitCompleteRefs -Current $right -Prefix "--force-with-lease=${left}:"
                }
                else {
                    gitCompleteRefs -Current $c -Prefix '--force-with-lease='
                }
                return
            }
            '--*' {
                gitCompleteResolveBuiltins $Context.Command -Current $Current
                return
            }
        }
    }
    gitCompleteRemoteOrRefspec $Context
}

function gitCompleteForceWithLease() {
    [OutputType([string[]])]
    param(
        [string]
        $Current
    )
    
    if ($Current.StartsWith('--')) { return @() }
    elseif ($Current -match '(.*):(.*)') { 
        gitCompleteRefs -Current $Matches[2] -Prefix ($Matches[1] + ':')
    }
    else {
        gitCompleteRefs -Current $Current
    }
}