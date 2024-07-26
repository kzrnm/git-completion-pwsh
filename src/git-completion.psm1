. $PSScriptRoot/CompletionRoot.ps1

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $CursorPosition)
    Initialize-GitComplete -CommandAst $commandAst -CursorPosition $CursorPosition
    return GitComplete
}

