using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-tag {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    $deleteOrVerify = $false
    $force = $false
    $Used = [List[string]]::new($Context.Words.Length)
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if ($i -lt $Context.DoubledashIndex) {
            if ($w -cmatch '^-([^-]*[dv][^-]*|-delete|-verify)$') {
                $deleteOrVerify = $true
            }
            elseif ($w -cmatch '^-([^-]*f[^-]*|-force)$') {
                $force = $true
            }
            elseif (!$w.StartsWith('-')) {
                $Used.Add($w)
            }
        }
        else {
            $Used.Add($w)
        }
    }

    if ($deleteOrVerify) {
        gitTags $Current | completeList -Current $Current -ResultType ParameterValue -Exclude $Used
        return
    }

    switch -CaseSensitive -Regex ($Context.PreviousWord()) {
        '^-([^-]*[Fm]|-message|-file)$' { return }
    }

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    if ($Used.Count -eq 0) {
        if ($force) {
            gitTags $Current | completeList -Current $Current -ResultType ParameterValue
        }
        return
    }

    gitCompleteRefs $Current
}