using namespace System.Management.Automation;

function Complete-GitSubCommand-help {
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

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
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
