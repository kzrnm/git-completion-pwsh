using namespace System.Management.Automation;

function Complete-GitSubCommand-help {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    if ($Current.StartsWith('--')) {
        gitCompleteResolveBuiltins $Context.command -Current $Current
        return
    }


    $aliases = @{}
    foreach ($a in (gitListAliases)) {
        $aliases[$a.Name] = "[alias] $($a.Value)"
    }

    @(gitAllCommands main nohelpers alias list-guide) + @('gitk') |
    completeList -Current $Context.CurrentWord() -ResultType ParameterValue -DescriptionBuilder {
        $a = $aliases[$_]
        if ($a) {
            $a
        }
        else {
            Get-GitCommandDescription $_ 
        }
    }
}
