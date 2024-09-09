using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-restore {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.command -Current $Current
        if ($shortOpts) { return $shortOpts }

        $prevCandidates = switch -CaseSensitive ($Context.PreviousWord()) {
            { $_ -cmatch '^-([^-]*s|-source)$' } {
                gitCompleteRefs -Current $Current
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
                '--source' {
                    gitCompleteRefs -Current $value -Prefix "$key="
                    return
                }
                '--conflict' { $gitConflictSolver }
            }

            if ($candidates) {
                $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.command -Current $Current
            return
        }
    }

    if (gitPseudorefExists HEAD) {
        $skipOptions = [System.Collections.Generic.List[string]]::new()
        foreach ($opt in (gitResolveBuiltins $Context.command -All)) {
            if ($opt.EndsWith('=')) {
                $skipOptions.Add($opt)
            }
        }
        $UsedPaths = [System.Collections.Generic.List[string]]::new($Context.Words.Length)
        for ($i = $Context.commandIndex + 1; $i -lt $Context.Words.Length; $i++) {
            if ($i -eq $Context.CurrentIndex) { continue }
            $w = $Context.Words[$i]
            if ($skipOptions.Contains($w)) { $i++ }
            elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
                $UsedPaths.Add($w)
            }
        }

        gitCompleteIndexFile -Current $Current -Options Modified -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
    }
}