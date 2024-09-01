using namespace System.Management.Automation;

function Complete-GitSubCommand-bundle {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $result = Complete-GitSubCommandCommon $Context
    if ($result) { return $result }

    if ($Context.SubcommandWithoutGlobalOption() -eq 'create') {
        if (($Context.CommandIndex + 2) -lt $Context.CurrentIndex) {
            gitCompleteRevlist $Context.CurrentWord()
        }
    }
}