# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-fetch {
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

        $gitFetchFilters = "blob:none", "blob:limit=", "sparse:oid="
        switch ($Prev) {
            '--recurse-submodules' {
                $script:gitFetchRecurseSubmodules | Complete-List -Current $Current -ResultType ParameterValue 
                return
            }
            '--filter' {
                $gitFetchFilters | Complete-List -Current $Current -ResultType ParameterValue 
                return
            }
        }

        switch -Wildcard ($Current) {
            '--recurse-submodules=*' { 
                $script:gitFetchRecurseSubmodules | Complete-List -Current $Current -ResultType ParameterValue -Prefix '--recurse-submodules=' -RemovePrefix
                return
            }
            '--filter=*' {
                $gitFetchFilters | Complete-List -Current $Current -ResultType ParameterValue -Prefix '--filter=' -RemovePrefix
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