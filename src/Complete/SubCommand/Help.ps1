# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
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
    Complete-List -Current $Context.CurrentWord() -ResultType ParameterValue -DescriptionBuilder {
        $a = $aliases[$_]
        if ($a) {
            $a
        }
        else {
            Get-GitCommandDescription $_ 
        }
    }
}
