# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
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
        $shortOpts = Get-GitShortOptions $Context.Command $subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current.StartsWith('--')) {
            if ($subcommand -eq 'show') {
                $gitLogCommonOptions | completeList -Current $Current -ResultType ParameterName
            }
            else {
                gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current
            }
            return
        }
    }

    gitCompleteRefs $Current
}