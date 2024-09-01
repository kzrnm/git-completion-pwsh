using namespace System.Management.Automation;

function Complete-GitSubCommand-archive {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        if ($Current -eq '-') {
            return Get-GitShortOptions $Context.command
        }

        $prevCandidates = switch -CaseSensitive ($Context.PreviousWord()) {
            '--format' { (gitArchiveList) }
            '--remote' { (gitRemote) }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=.*') {
            $key = $Matches[1]
            $candidates = switch -CaseSensitive ($key) {
                '--format' { (gitArchiveList) }
                '--remote' { (gitRemote) }
            }

            if ($candidates) {
                $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.command -Current $Current -Include @(
                '--format=',
                '--list',
                '--verbose',
                '--prefix=',
                '--worktree-attributes'
            )
            return
        }
    }

    gitCompleteFile $Context.CurrentWord()
}