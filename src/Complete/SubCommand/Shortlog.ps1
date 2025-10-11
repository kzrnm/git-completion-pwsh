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

        $prevCandidates = switch -CaseSensitive ($Context.PreviousWord()) {
            '--exclude' { gitCompleteLogExclude $Context $Current }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }


        if ($Current.StartsWith('--')) {
            if ($Current -cmatch '(--[^=]+)=(.*)') {
                $key = $Matches[1]
                $value = $Matches[2]
                $candidates = switch -CaseSensitive ($key) {
                    '--exclude' { gitCompleteLogExclude $Context $value }
                }

                if ($candidates) {
                    $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                    return
                }
            }


            $gitShortlogOptions | completeList -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
            return
        }

        gitCompleteRevlist $Current
    }
}
