$path = "${env:TMP}/GitCompletionLauncher/"

mkdir $path -Force
Copy-Item -Force -Recurse "$PSScriptRoot/../GitCompletionCore/bin/Debug/netstandard2.0/*" "$path/"
Copy-Item -Force -Recurse "$PSScriptRoot/../../src/*" "$path/"

if (!(Test-Path "$path/git-completion.psd1")) {
    throw "See launch.ps1"
}

Import-Module "$path/git-completion.psd1" -Force

$line = 'git log '
$ast = ([System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null).EndBlock.Statements.PipelineElements)
Complete-GitCore -CommandAst $ast -CursorPosition $line.Length
