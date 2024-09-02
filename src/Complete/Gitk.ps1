using namespace System.Management.Automation;

function Complete-Gitk {
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