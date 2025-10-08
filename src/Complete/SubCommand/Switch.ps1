# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-switch {
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

        switch -CaseSensitive ($Context.PreviousWord()) {
            { $_ -cmatch '^-([^-]*[cC]|-orphan)$' } {
                gitCompleteRefs -Current $Current -Mode heads -dwim:(checkoutDefaultDwimMode $Context)
                return
            }
            '--conflict' {
                $gitConflictSolver | completeTipList -Current $Current -ResultType ParameterValue
                return
            }
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            switch -CaseSensitive ($key) {
                '--orphan' {
                    gitCompleteRefs $value -Mode heads -dwim:(checkoutDefaultDwimMode $Context) -Prefix "$key="
                    return
                }
                '--conflict' {
                    $gitConflictSolver | completeTipList -Current $value -Prefix "$key=" -ResultType ParameterValue
                    return
                }
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    # At this point, we've already handled special completion for
    # the arguments to -b/-B, and --orphan. There are 3 main
    # things left we can possibly complete:
    # 1) a start-point for -b/-B, -d/--detach, or --orphan
    # 2) a remote head, for --track
    # 3) an arbitrary reference, possibly including DWIM names
    #

    $startPoint = $false
    $remoteHead = $false

    for ($i = $Context.CommandIndex + 1; $i -lt $Context.DoubledashIndex; $i++) {
        $w = $Context.Words[$i]
        if ($w -ceq '--orphan') {
            # Unlike in git checkout, git switch --orphan does not take
            # a start point. Thus we really have nothing to complete after
            # the branch name.
            return
        }
        elseif ($w -cmatch '^-([^-]*[cCd][^-]*|-detach)$') {
            $startPoint = $true
        }
        elseif ($w -cmatch '^-([^-]*t[^-]*|-track)$') {
            $remoteHead = $true
        }
    }
    if ($startPoint) {
        gitCompleteRefs -Current $Current -Mode refs
    }
    elseif ($remoteHead) {
        gitCompleteRefs -Current $Current -Mode remote-heads
    }
    else {
        gitCompleteRefs -Current $Current -Mode heads -dwim:(checkoutDefaultDwimMode $Context)
    }
}