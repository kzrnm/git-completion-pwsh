using namespace System.Management.Automation;

function Complete-Gitk {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [string[]][AllowEmptyCollection()][AllowEmptyString()][Parameter(Mandatory)]$Words,
        [int]$CurrentIndex = -1
    )

    if ($CurrentIndex -lt 0) { $CurrentIndex = $Words.Length - 1 }
    $Context = [CommandLineContext]::new($Words, $CurrentIndex)

    if ($Context.HasDoubledash()) { return }

    $Current = $Context.CurrentWord()
    
    if ($Current.StartsWith('--')) {
        gitkOpts -Merge:(gitPseudorefExists MERGE_HEAD) | completeList -Current $Current -ResultType ParameterName
        return
    }

    gitCompleteRevlist $Current
}

function gitkOpts {
    [OutputType([string[]])]
    param (
        [switch]$Merge
    )
    
    $gitLogCommonOptions
    $gitLogGitkOptions
    if ($Merge) { '--merge' }
}