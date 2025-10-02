# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-format-patch {
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

        switch -CaseSensitive -Regex ($Context.PreviousWord()) {
            '^--(base|interdiff|range-diff)$' { gitCompleteRefs $Current; return }
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive -Regex ($key) {
                '^--thread$' { 'deep', 'shallow' }
                '^--(base|interdiff|range-diff)$' { gitCompleteRefs $value -Prefix "$key="; return }
            }

            if ($candidates) {
                $candidates | Complete-List -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current -Include $gitFormatPatchExtraOptions
            return
        }
    }

    gitCompleteRevlist $Current
}

$gitFormatPatchExtraOptions = '--full-index', '--not', '--all', '--no-prefix', '--src-prefix=', '--dst-prefix=', '--notes'