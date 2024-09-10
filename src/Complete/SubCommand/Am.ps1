using namespace System.Management.Automation;

function Complete-GitSubCommand-am {
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
            '--whitespace' { $script:gitWhitespacelist }
            '--patch-format' { $script:gitPatchformat }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--whitespace' { $script:gitWhitespacelist }
                '--patch-format' { $script:gitPatchformat }
                '--show-current-patch' { $script:gitShowcurrentpatch }
                '--quoted-cr' { $script:gitQuotedCr }
            }

            if ($candidates) {
                $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
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
}