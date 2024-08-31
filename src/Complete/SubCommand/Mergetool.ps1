using namespace System.Management.Automation;

function Complete-GitSubCommand-mergetool {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return @(
            [CompletionResult]::new(
                '-g',
                '-g',
                'ParameterName',
                "--gui"
            ),
            [CompletionResult]::new(
                '-O',
                '-O',
                'ParameterName',
                "Process files in the order specified"
            ),
            [CompletionResult]::new(
                '-y',
                '-y',
                'ParameterName',
                "Don’t prompt before each invocation of the merge resolution program"
            ),
            $__helpCompletion
        )
    }

    $prevCandidates = switch ($Context.PreviousWord()) {
        '--tool' { ($gitMergetoolsCommon + @('tortoisemerge')) }
    }

    if ($prevCandidates) {
        $prevCandidates | completeList -Current $Current -ResultType ParameterValue
        return
    }
    if ($Current -cmatch '(--[^=]+)=.*') {
        $key = $Matches[1]
        $candidates = switch ($key) {
            '--tool' { ($gitMergetoolsCommon + @('tortoisemerge')) }
        }

        if ($candidates) {
            $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
            return
        }
    }

    if ($Current.StartsWith('--')) {
        '--tool=', '--prompt', '--no-prompt', '--gui', '--no-gui' | completeList -Current $Current
        return
    }
}