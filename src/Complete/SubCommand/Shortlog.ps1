# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-shortlog {
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
            ($gitLogCommonOptions + $gitLogShortlogOptions + @('--numbered', '--summary', '--email', '--no-committer', '--no-numbered', '--no-summary', '--no-email')) |
            completeList -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
            return
        }

        gitCompleteRevlist $Current
    }
}
