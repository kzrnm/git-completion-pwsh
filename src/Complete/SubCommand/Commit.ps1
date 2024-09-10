using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-commit {
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

        $prevCandidates = switch -CaseSensitive -Regex ($Context.PreviousWord()) {
            '^-[^-]*[cC]$' { gitCompleteRefs $Current; return }
            '^--cleanup$' { 'default', 'scissors', 'strip', 'verbatim', 'whitespace' }
            '^--(reuse-message|reedit-message|fixup|squash)$' { gitCompleteRefs $Current; return }
            '^--untracked-files$' { $script:gitUntrackedFileModes }
            '^--trailer$' { gitTrailerTokens }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive -Regex ($key) {
                '^--cleanup$' { 'default', 'scissors', 'strip', 'verbatim', 'whitespace' }
                '^--(reuse-message|reedit-message|fixup|squash)$' { gitCompleteRefs $value -Prefix "$key="; return }
                '^--untracked-files$' { $script:gitUntrackedFileModes }
                '^--trailer$' { gitTrailerTokens }
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
    }

    $skipOptions = [HashSet[string]]::new()
    foreach ($opt in (gitResolveBuiltins $Context.Command -All)) {
        if ($opt.EndsWith('=')) {
            $skipOptions.Add($opt) | Out-Null
        }
    }
    $UsedPaths = [List[string]]::new($Context.Words.Length)
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if ($skipOptions.Contains($w)) { $i++ }
        elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
            $UsedPaths.Add($w)
        }
    }

    __git rev-parse --verify --quiet HEAD | Out-Null
    $completeOpt = if ($LASTEXITCODE -eq 0) {
        [IndexFilesOptions]::Committable
    }
    else {
        # This is the first commit
        [IndexFilesOptions]::Cached
    }
    gitCompleteIndexFile -Current $Current -Options $completeOpt -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
}

function gitTrailerTokens {
    [OutputType([string[]])]
    param ()

    $regex = '^trailer\.(.*)\.key$'
    __git config --name-only --get-regexp $regex | ForEach-Object {
        if ($_ -cmatch $regex) {
            $Matches[1]
        }
    }
}