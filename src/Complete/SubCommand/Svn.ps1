# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-svn {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    $Subcommand = $Context.SubcommandWithoutGlobalOption()
    if (!$Subcommand) {
        'init', 'fetch', 'clone', 'rebase', 'dcommit', 'log',
        'find-rev', 'set-tree', 'commit-diff', 'info',
        'create-ignore', 'propget', 'proplist', 'show-ignore',
        'show-externals', 'branch', 'tag', 'blame',
        'migrate', 'mkdirs', 'reset', 'gc' | completeList -Current $Current -ResultType ParameterName
        return
    }

    if (!$Context.HasDoubledash() -and $Current.StartsWith('--')) {
        $remoteOpts = '--username=', '--config-dir=', '--no-auth-cache'
        $fcOpts = @('--follow-parent', '--authors-file=', '--repack=', '--no-metadata', '--use-svm-props', '--use-svnsync-props', '--log-window-size=', '--no-checkout', '--quiet', '--repack-flags', '--use-log-author', '--localtime', '--add-author-from', '--recursive', '--ignore-paths=', '--include-paths=') + $remoteOpts
        $initOpts = @('--template=', '--shared=', '--trunk=', '--tags=', '--branches=', '--stdlayout', '--minimize-url', '--no-metadata', '--use-svm-props', '--use-svnsync-props', '--rewrite-root=', '--prefix=') + $remoteOpts
        $cmtOpts = '--edit', '--rmdir', '--find-copies-harder', '--copy-similarity='
        
        $Candidates = switch ($Subcommand) {
            'fetch' { @('--revision=', '--fetch-all') + $fcOpts }
            'clone' { @('--revision=') + $fcOpts + $initOpts }
            'init' { $initOpts }
            'dcommit' {
                @('--merge', '--strategy=', '--verbose', '--dry-run', '--fetch-all', '--no-rebase', '--commit-url', '--revision', '--interactive') + $cmtOpts + $fcOpts
            }
            'set-tree' {
                @('--stdin') + $cmtOpts + $fcOpts
            }
            'rebase' {
                @('--merge', '--verbose', '--strategy=', '--local', '--fetch-all', '--dry-run') + $fcOpts
            }
            'commit-diff' {
                @('--message=', '--file=', '--revision=') + $cmtOpts
            }
            'log' { '--limit=', '--revision=', '--verbose', '--incremental', '--oneline', '--show-commit', '--non-recursive', '--authors-file=', '--color' }
            'info' { '--url' }
            'branch' { '--dry-run', '--message', '--tag' }
            'tag' { '--dry-run', '--message' }
            'blame' { '--git-format' }
            'migrate' { '--config-dir=', '--ignore-paths=', '--minimize', '--no-auth-cache', '--username=' }
            'reset' { '--revision=', '--parent' }
            { $_ -cin 'create-ignore', 'propget', 'proplist', 'show-ignore', 'show-externals', 'mkdirs' } { '--revision=' }
        }

        $Candidates | completeList -Current $Current -ResultType ParameterName
    }
}