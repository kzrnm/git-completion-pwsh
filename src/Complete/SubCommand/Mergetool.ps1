using namespace System.Management.Automation;

function Complete-GitSubCommand-mergetool {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if (!$Context.HasDoubledash()) {
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

        if ($Context.PreviousWord() -ceq '--tool') {
            $gitMergetoolsMergeTool | completeList -Current $Current -ResultType ParameterValue
            return
        }
        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]

            if ($key -ceq '--tool') {
                $gitMergetoolsMergeTool | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            '--tool=', '--tool-help', '--prompt', '--no-prompt', '--gui', '--no-gui' | completeList -Current $Current
            return
        }
    }
}