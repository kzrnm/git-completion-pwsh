using namespace System.Management.Automation;

function Complete-GitSubCommand-branch {
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

        switch ($Context.PreviousWord()) {
            '--set-upstream-to' {
                return @(gitCompleteRefs $Current)            
            }
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            switch ($key) {
                '--set-upstream-to' {
                    $rt = @(gitCompleteRefs $Matches[2] -Prefix "$key=")
                    return $rt
                }
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    $onlyLocalRef = $false
    $hasR = $false
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.DoubledashIndex; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if ($w -cmatch '^-([^-]*[dDmMcC][^-]*|-delete|-move|-copy)$') {
            $onlyLocalRef = $true
        }
        if ($w -cmatch '^-([^-]*r[^-]*|-remotes)$') {
            $hasR = $true
        }
    }

    if ($onlyLocalRef -and !$hasR) {
        gitHeads $Current | completeList -Current $Current -ResultType ParameterValue
    }
    else {
        gitCompleteRefs $Current
    }
}