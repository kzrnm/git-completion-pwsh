using namespace System.Management.Automation;

function Complete-GitSubCommand-checkout {
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
            { $_ -cmatch '^-([^-]*[bB]|-orphan)$' } {
                gitCompleteRefs $Current -Mode heads -dwim:(checkoutDefaultDwimMode $Context)
                return
            }
            '--conflict' { $gitConflictSolver }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--orphan' {
                    gitCompleteRefs $value -Mode heads -dwim:(checkoutDefaultDwimMode $Context) -Prefix "$key="
                    return
                }
                '--conflict' { $gitConflictSolver }
            }

            if ($candidates) {
                $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
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
            if ($w -cmatch '^-([^-]*[bBd][^-]*|-detach|-orphan)$') {
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
            gitCompleteRefs -Current $Current -Mode refs -dwim:(checkoutDefaultDwimMode $Context)
        }
    }
}

# __git_checkout_default_dwim_mode
# Helper function to decide whether or not we should enable DWIM logic for
# git-switch and git-checkout.
#
# To decide between the following rules in decreasing priority order:
# - the last provided of "--guess" or "--no-guess" explicitly enable or
#   disable completion of DWIM logic respectively.
# - If checkout.guess is false, disable completion of DWIM logic.
# - If the --no-track option is provided, take this as a hint to disable the
#   DWIM completion logic
# - If GIT_COMPLETION_CHECKOUT_NO_GUESS is set, disable the DWIM completion
#   logic, as requested by the user.
# - Enable DWIM logic otherwise.
#
function checkoutDefaultDwimMode {
    [OutputType([bool])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $noTrack = $false
    for ($i = $Context.DoubledashIndex - 1; $i -gt $Context.CommandIndex; $i--) {
        switch ($Context.Words[$i]) {
            '--guess' { return $true }
            '--no-guess' { return $false }
            '--no-track' { $noTrack = $true }
        }
    }

    # checkout.guess = false disables DWIM, but with lower priority than
    # --guess/--no-guess
    if ((__git config --type=bool checkout.guess) -ceq 'false') {
        return $false
    }

    # --no-track disables DWIM, but with lower priority than
    # --guess/--no-guess/checkout.guess
    if ($noTrack) { return $false }

    if ($script:GitCompletionSettings.CheckoutNoGuess) { return $false }
    return $true
}
