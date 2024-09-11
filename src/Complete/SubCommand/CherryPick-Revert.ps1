# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-cherry-pick {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    completeCherryPickOrRevert $Context CHERRY_PICK_HEAD
}


function Complete-GitSubCommand-revert {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    completeCherryPickOrRevert $Context REVERT_HEAD
}


function completeCherryPickOrRevert {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context,
        [string]
        [Parameter(Position = 1, Mandatory)]$InProgressRef
    )
    
    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        if(gitPseudorefExists $InProgressRef){
            $gitCherryPickInprogressOptions | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
            return
        }

        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        $result = gitCompleteStrategy -Current $Current -Prev $Context.PreviousWord()
        if ($null -ne $result) { return $result }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current -Exclude $gitCherryPickInprogressOptions
            return
        }
    }

    gitCompleteRefs $Current
}