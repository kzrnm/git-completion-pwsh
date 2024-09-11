# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-rebase {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        $repoPath = (gitRepoPath)
        if (Test-Path "$repoPath/rebase-merge/interactive" -PathType Leaf) {
            $gitRebaseInteractiveInprogressOptions | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
            return
        }
        elseif ((Test-Path "$repoPath/rebase-apply" -PathType Container) -or (Test-Path "$repoPath/rebase-merge" -PathType Container)) {
            $gitRebaseInprogressOptions | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
            return
        }

        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        $result = gitCompleteStrategy -Current $Current -Prev $Context.PreviousWord()
        if ($null -ne $result) { return $result }

        $prevCandidates = switch -CaseSensitive ($Context.PreviousWord()) {
            '--whitespace' { $gitWhitespacelist }
            '--onto' { 
                gitCompleteRefs $Current
                return
            }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--whitespace' { $gitWhitespacelist }
                '--onto' { 
                    gitCompleteRefs $value -Prefix "--onto="
                    return
                }
            }

            if ($candidates) {
                $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current -Exclude $gitRebaseInteractiveInprogressOptions
            return
        }
    }

    gitCompleteRefs $Current
}