using namespace System.Management.Automation;

function Complete-GitSubCommand-am {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    $prevCandidates = switch ($Context.PreviousWord()) {
        '--whitespace' { $script:gitWhitespacelist }
        '--patch-format' { $script:gitPatchformat }
    }

    if ($prevCandidates) {
        $prevCandidates | completeList -Current $Current -ResultType ParameterValue
        return
    }

    if ($Current -cmatch '(--[^=]+)=.*') {
        $key = $Matches[1]
        $candidates = switch ($key) {
            '--whitespace' { $script:gitWhitespacelist }
            '--patch-format' { $script:gitPatchformat }
            '--show-current-patch' { $script:gitShowcurrentpatch }
            '--quoted-cr' { $script:gitQuotedCr }
        }

        if ($candidates) {
            $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
            return
        }
    }

    if (Test-Path "$(gitRepoPath)/rebase-apply" -PathType Container) {
        $gitAmInprogressOptions | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.Command }
        return
    }

    if ($Current.StartsWith('--')) {
        gitCompleteResolveBuiltins $Context.Command -Current $Current -Exclude $gitAmInprogressOptions
        return
    }
}