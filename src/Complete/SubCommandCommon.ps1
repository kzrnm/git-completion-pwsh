# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
function Complete-GitSubCommandCommon {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $Current = $Context.CurrentWord()
    $Command = $Context.Command

    [string] $Subcommand = $Context.Subcommand()

    if ($Subcommand -and ($Subcommand -cnotlike '*[:/\]*')) {
        if (!$Context.HasDoubledash()) {
            if ($Current -cmatch '^-[^-]*$') {
                $shortOpts = Get-GitShortOptions $Command $Subcommand -Current $Current
                if ($shortOpts) { return $shortOpts }
                Get-GitShortOptions $Command -Current $Current
                return
            }
            if ($Current.StartsWith('--')) {
                $result = gitCompleteResolveBuiltins $Command $Subcommand -Current $Current -Check
                if ($result) {
                    return $result
                }
                gitCompleteResolveBuiltins $Command -Current $Current -Check
                return
            }
        }
    }
    else {
        if (!$Context.HasDoubledash()) {
            $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
            if ($shortOpts) { return $shortOpts }
            elseif (!$Current) {
                gitCompleteResolveBuiltins $Command -Current $Current -Check | Where-Object { !$_.CompletionText.StartsWith('-') }
            }
            else {
                gitCompleteResolveBuiltins $Command -Current $Current -Check
            }
        }
        return
    }
}