# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-remote {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    [string] $subcommand = $Context.Subcommand()
    $subcommands = gitResolveBuiltins $Context.Command | Where-Object {
        (!$_.StartsWith('--')) -and ($_ -ne 'rm')
    }

    if (!$subcommand) {
        if (!$Context.HasDoubledash()) {
            $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
            if ($shortOpts) { return $shortOpts }
            elseif ($Current.StartsWith('--')) {
                gitCompleteResolveBuiltins $Context.Command -Current $Current
            }
            else {
                $subcommands | Complete-List -Current $Current -DescriptionBuilder { 
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
        }
        return
    }
    if ($subcommand -notin $subcommands) { return }

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command $subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }
        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current
            return
        }
    }

    switch ($subcommand) {
        'add' {  }
        ({ $_ -in @('set-head', 'set-branches') }) {
            gitCompleteRemoteOrRefspec $Context
        }
        'update' {
            gitRemote | Complete-List -Current $Current -ResultType ParameterValue
            gitGetConfigVariables 'remotes' | Complete-List -Current $Current -ResultType ParameterValue
        }
        default {
            gitRemote | Complete-List -Current $Current -ResultType ParameterValue
        }
    }
}
