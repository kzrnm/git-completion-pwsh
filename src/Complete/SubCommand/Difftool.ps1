# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-difftool {
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
            '--tool' { ($gitMergetoolsCommon + @('kompare')) }
        }

        if ($prevCandidates) {
            $prevCandidates | Complete-List -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--tool' { ($gitMergetoolsCommon + @('kompare')) }
            }

            if ($candidates) {
                $candidates | Complete-List -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            $gitDiffDifftoolOptions | Complete-List -Current $Current
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    gitCompleteRevlistFile $Current
}