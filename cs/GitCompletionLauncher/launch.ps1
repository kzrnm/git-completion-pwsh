mkdir "$PSScriptRoot/proj" -Force
Copy-Item -Force -Recurse "$PSScriptRoot/../GitCompletionCore/bin/Debug/netstandard2.0/*" "$PSScriptRoot/proj/"

# Comment out if necessary
# Copy-Item -Force -Recurse "$PSScriptRoot/../../src/*" "$PSScriptRoot/proj/"

if (!(Test-Path "$PSScriptRoot/proj/git-completion.psd1")) {
    throw "See launch.ps1"
}

Import-Module "$PSScriptRoot/proj/git-completion.psd1" -Force

$line = 'git log '
$ast = ([System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null).EndBlock.Statements.PipelineElements)
Complete-GitCore -CommandAst $ast -CursorPosition $line.Length
