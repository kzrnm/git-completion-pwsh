using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-notes {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    $Subcommands = [List[string]]::new()
    $Options = [List[string]]::new()
    foreach ($c in @(gitResolveBuiltins $Context.Command)) {
        if ($c.StartsWith('-')) {
            $Options.Add($c)
        }
        else {
            $Subcommands.Add($c)
        }
    }

    for ($i = 0; $i -lt $Context.DoubledashIndex; $i++) {
        if ($Context.Words[$i] -cin $Subcommands) {
            $Subcommand = $Context.Words[$i]
        }
    }

    if (!$Subcommand) {
        if (!$Context.HasDoubledash()) {
            $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
            if ($shortOpts) { return $shortOpts }

            if ($Context.PreviousWord() -ceq '--ref') {
                gitCompleteRefs $Current
                return
            }

            if ($Current -cmatch '^(--ref)=(.*)') {
                $value = $Matches[2]
                gitCompleteRefs $value -Prefix '--ref='
                return
            }

            $SubcommandsOrOptions = if ($Current.StartsWith('-')) {
                $Options
            }
            else {
                $Subcommands
            }

            $SubcommandsOrOptions | gitcomp -Current $Current -DescriptionBuilder { 
                switch ($_) {
                    'list' { 'list the notes object' }
                    'add' { 'add notes' }
                    'copy' { 'copy the notes for the first object onto the second object ' }
                    'append' { 'append new message(s) ' }
                    'edit' { 'edit the notes' }
                    'show' { 'show the notes' }
                    'merge' { 'merge the given notes ref into the current notes ref' }
                    'remove' { 'remove the notes' }
                    'prune' { 'remove all notes for non-existing/unreachable objects' }
                    'get-ref' { 'print the current notes ref' }
                    Default { Get-GitOptionsDescription $_ $Context.Command }
                }
            }
            return
        }
    }

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command $Subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }

        switch -CaseSensitive -Regex ($Context.PreviousWord()) {
            '^-[^-]*[mF]$' { return }
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            switch -CaseSensitive -Regex ($key) {
                '^--(reuse|reedit)-message$' {
                    gitCompleteRefs $value -Prefix "$key="
                    return
                }
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command $Subcommand -Current $Current
            return
        }
    }

    if ($Subcommand -cin 'prune', 'get-ref') { return }

    gitCompleteRefs $Current
}