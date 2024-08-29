function Complete-GitSubCommandCommon {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $Current = $Context.CurrentWord()
    $Command = $Context.command

    [string] $subcommand = $Context.Subcommand()
    if ((!$subcommand) -or $subcommand.StartsWith('-')) {
        $subcommand = ''
    }

    if ($Current -eq '-') {
        Get-GitShortOptions $Command $subcommand 
        return
    }
    # elseif (gitSupportParseoptHelper $Command) {
    if ($Current.StartsWith('--')) {
        if ($subcommand) {
            $Commands = @($Command, $subcommand)
        }
        else {
            $Commands = @($Command)
        }

        gitCompleteResolveBuiltins @Commands -Current $Current
        return
    }
}