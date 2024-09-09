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
        $shortOpts = Get-GitShortOptions $Context.command -Current $Current
        if ($shortOpts) { return $shortOpts }

        if(gitPseudorefExists $InProgressRef){
            $gitCherryPickInprogressOptions | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
            return
        }
    
        $result = gitCompleteStrategy -Current $Current -Prev $Context.PreviousWord()
        if ($null -ne $result) { return $result }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current -Exclude $gitCherryPickInprogressOptions
            return
        }
    }

    gitCompleteRefs $Current
}