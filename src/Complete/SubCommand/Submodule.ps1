# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-submodule {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    $Subcommand = $Context.SubcommandWithoutGlobalOption()
    if (!$Subcommand) {
        'add', 'status', 'init', 'deinit', 'update', 'set-branch', 'set-url', 'summary', 'foreach', 'sync', 'absorbgitdirs' |
        completeList -Current $Current -ResultType ParameterName -DescriptionBuilder {
            switch ($_) {
                'add' { 'add the given repository as a submodule' }
                'status' { 'show the status of the submodules' }
                'init' { 'initialize the submodules' }
                'deinit' { 'unregister the given submodules' }
                'update' { 'update the registered submodules' }
                'set-branch' { 'sets the default remote tracking branch for the submodule' }
                'set-url' { 'sets the url of the specified submodule to <newurl>' }
                'summary' { 'show commit summary between the given commit' }
                'foreach' { 'evaluates an arbitrary shell command in each checked out submodule' }
                'sync' { 'synchronizes submodules'' remote URL configuration setting to the value specified in .gitmodules' }
                'absorbgitdirs' { "move the git directory of the submodule into its superproject’s `$GIT_DIR/modules path" }
            }
        }
        return
    }

    if (!$Context.HasDoubledash() -and $Current.StartsWith('--')) {
        $Candidates = switch ($Subcommand) {
            'add' { '--branch', '--force', '--name', '--reference', '--depth' }
            'status' { '--cached', '--recursive' }
            'deinit' { '--force', '--all' }
            'update' { '--init', '--remote', '--no-fetch', '--recommend-shallow', '--no-recommend-shallow', '--force', '--rebase', '--merge', '--reference', '--depth', '--recursive', '--jobs' }
            'set-branch' { '--default', '--branch' }
            'summary' { '--cached', '--files', '--summary-limit' }
            { $_ -cin 'foreach', 'sync' } { '--recursive' }
        }

        $Candidates | completeList -Current $Current -ResultType ParameterName
    }
}