using namespace System.Management.Automation;

function Complete-GitSubCommand-reflog {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    $subcommands = gitResolveBuiltins $Context.Command
    [string] $subcommand = $Context.SubcommandWithoutGlobalOption()
    if (!$subcommand) {
        $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
            switch ($_) {
                "show" { 'shows the log of the reference (default)' }
                "list" { 'lists all refs' }
                "expire" { 'prunes older reflog entries' }
                "delete" { 'deletes single entries' }
                "exists" { 'checks whether a ref has a reflog' }
            }
        }

        $subcommand = 'show'
    }

    if (!$Context.HasDoubledash()) {
        if ($Current -eq '-') {
            return Get-GitShortOptions $Context.Command $subcommand
        }

        if ($Current.StartsWith('--')) {
            if ($subcommand -eq 'show') {
                $gitLogCommonOptions | completeList -Current $Current -ResultType ParameterName
            }
            else {
                gitCompleteResolveBuiltins $Context.command $subcommand -Current $Current
            }
            return
        }
    }

    gitCompleteRefs $Current
}