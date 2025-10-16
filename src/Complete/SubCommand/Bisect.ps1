# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-bisect {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )


    [string] $Current = $Context.CurrentWord()
    [string] $subcommand = $Context.SubcommandWithoutGlobalOption()
    
    $repoPath = (gitRepoPath)

    if (Test-Path "$repoPath/BISECT_TERMS" -PathType Leaf) {
        $goodTerm = [string](__git bisect terms --term-good)
        $badTerm = [string](__git bisect terms --term-bad)
    }
    else {
        $goodTerm = 'good'
        $badTerm = 'bad'
    }

    if (!$subcommand) {
        if (!$Context.HasDoubledash()) {
            $subcommands = if (Test-Path "$repoPath/BISECT_START" -PathType Leaf) {
                @($goodTerm, $badTerm) + @(gitResolveBuiltins $Context.Command)
            }
            else {
                'start', 'replay'
            }
    
            $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                switch ($_) {
                    { $_ -ceq $goodTerm } {
                        'mark the commit as good';                        break 
                    }
                    { $_ -ceq $badTerm } { 'mark the commit as bad'; break }
                    'reset' { 'clean up the bisection state' }
                    'terms' { 'get a reminder of the currently used terms' }
                    'start' { 'start bisection state' }
                    'terms' { 'get a reminder of the currently used terms' }
                    'log' { 'show what has been done so far' }
                    'replay' { 'show what has been done so far from logfile' }
                    'skip' { 'skip a commit adjacent' }
                    'visualize' { 'see the currently remaining suspects in gitk' }
                    'view' { 'see the currently remaining suspects in gitk' }
                    'run' { 'bisect by issuing the command' }
                }
            }
        }
        return
    }

    if ($subcommand -cin 'start', $badTerm, $goodTerm, 'reset', 'skip') {
        if ($Subcommand -ceq 'start') {
            if (!$Context.HasDoubledash()) {
                if ($Current.StartsWith('--')) {
                    '--first-parent', '--no-checkout', '--term-new', '--term-bad', '--term-old', '--term-good' |
                    completeList -Current $Current
                    return
                }
            }
        }
        gitCompleteRefs $Current
    }
    elseif ($subcommand -ceq 'terms') {
        if ($Current.StartsWith('--')) {
            '--term-good', '--term-old', '--term-bad', '--term-new' |
            completeList -Current $Current
            return
        }
    }
    elseif ($subcommand -cin 'view', 'visualize') {
        gitCompleteLogOpts $Context
    }
}