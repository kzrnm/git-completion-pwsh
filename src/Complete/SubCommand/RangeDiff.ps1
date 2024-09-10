using namespace System.Management.Automation;

function Complete-GitSubCommand-range-diff {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        $result = Complete-Opts-range-diff $Context
        if ($result) { return $result }
    }
    gitCompleteRevlistFile $Current
}

function Complete-Opts-range-diff {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param (
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current.StartsWith('--')) {
        '--creation-factor=', '--no-dual-color' | completeList -Current $Current
        $script:gitDiffCommonOptions | completeList -Current $Current
        return
    }
}
