param([Parameter(Position=0)]$Line)

Import-Module "$PSScriptRoot/../../cs/bin/Debug/netstandard2.0/git-completion-core.dll"

[System.Diagnostics.Trace]::Listeners.Add(
   [System.Diagnostics.TextWriterTraceListener]::new([Console]::Error)) | Out-Null;

function Complete-FromLine {
    param (
        [string][Parameter(ValueFromPipeline)] $line,
        [string]$Right = ''
    )

    switch -Wildcard ($line) {
        'gitk *' {
            Set-Alias Complete Complete-Gitk -Scope Local
            break
        }
        'git *' {
            Set-Alias Complete Complete-Git -Scope Local
            break
        }
        Default { throw 'Invalid input' }
    }

    $CommandAst = [System.Management.Automation.Language.Parser]::ParseInput($line + $Right, [ref]$null, [ref]$null).EndBlock.Statements.PipelineElements
    $CursorPosition = $line.Length
    return (Complete -CommandAst $CommandAst -CursorPosition $CursorPosition)
}

if($Line){
    "$Line" |Complete-FromLine
}
elseif (Test-Path "$PSScriptRoot/args.txt"){
	(Get-Content "$PSScriptRoot/args.txt" -Raw) | Complete-FromLine
}