using namespace System.Management.Automation;

function Complete-GitSubCommand-remote {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    [string[]] $trailingWords = $Context.WordsWithoutLeadingOptions()

    [string] $subcommand = ''
    if ($trailingWords.Length -gt 1) {
        $subcommand = $trailingWords[0]
    }
    $subcommands = gitResolveBuiltins $Context.command | Where-Object {
        (!$_.StartsWith('--')) -and ($_ -ne 'rm')
    }

    if (!$subcommand) {
        if ($Current -eq '-') {
            Get-GitShortOptions $Context.command
        }
        elseif ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.command -Current $Current
        }
        else {
            $subcommands | completeList -Current $Current -DescriptionBuilder { 
                switch ($_) {
                    'add' { 'Add a remote' }
                    'get-url' { 'Retrieves the URLs for a remote' }
                    'prune' { 'Deletes stale references' }
                    'remove' { 'Remove the remote name' }
                    'rename' { 'Rename the remote name' }
                    'set-branches' { 'Changes the list of branches tracked by the named remote' }
                    'set-head' { 'Sets or deletes the default branch for the named remote' }
                    'set-url' { 'Changes URLs for the remote' }
                    'show' { 'Gives some information' }
                    'update' { 'Fetch updates for remotes or remote groups' }
                }
            }
        }
        return
    }
    if ($subcommand -notin $subcommands) { return }

    if ($Current -eq '-') {
        Get-GitShortOptions $Context.command $subcommand
        return
    }
    if ($Current.StartsWith('--')) {
        gitCompleteResolveBuiltins $Context.command $subcommand -Current $Current
        return
    }

    switch ($subcommand) {
        'add' {  }
        ({ $_ -in @('set-head', 'set-branches') }) {
            gitCompleteRemoteOrRefspec $Context
        }
        'update' {
            gitRemote | completeList -Current $Current -ResultType ParameterValue
            gitGetConfigVariables 'remotes' | completeList -Current $Current -ResultType ParameterValue
        }
        default {
            gitRemote | completeList -Current $Current -ResultType ParameterValue
        }
    }
}
