. $PSScriptRoot/CompletionRoot.ps1
$ErrorActionPreference = 'Continue'

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $CursorPosition)
    return (Complete-Git-Ast -CommandAst $commandAst -CursorPosition $CursorPosition)
}
