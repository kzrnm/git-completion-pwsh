function Complete-GitSubCommandCommon {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $Current = $Context.CurrentWord()

    if (($Current.StartsWith('--')) -and (gitSupportParseoptHelper $Context.command)) {
        gitResolveBuiltins $Context.command | gitcomp -Current $Current
        return
    }
}