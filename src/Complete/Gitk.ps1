# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-Gitk {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'String')]
        [string[]]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $Words,
        [Parameter(ParameterSetName = 'String')]
        [int]
        $CurrentIndex = -1,
        [Parameter(Mandatory, ParameterSetName = 'Ast')]
        [Language.CommandAst]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $CommandAst,
        [Parameter(Mandatory, ParameterSetName = 'Ast')]
        [int]
        $CursorPosition
    )

    if ($PSCmdlet.ParameterSetName -eq 'Ast') {
        $Words, $CurrentIndex = buildWords $CommandAst $CursorPosition
    }

    if ($CurrentIndex -lt 0) { $CurrentIndex = $Words.Length - 1 }
    $Context = [CommandLineContext]::new($Words, $CurrentIndex)

    if ($Context.HasDoubledash()) { return }
    $Current = $Context.CurrentWord()

    if ($Current.StartsWith('--')) {
        $gitLogCommonOptions | completeTipList -Current $Current -ResultType ParameterName
        $gitLogGitkOptions | completeTipList -Current $Current -ResultType ParameterName
        if (gitPseudorefExists MERGE_HEAD) {
            '--merge' | completeList -Current $Current -ResultType ParameterName
        }
        return
    }

    gitCompleteRevlist $Current
}
