. $PSScriptRoot/CompletionRoot.ps1

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $commandAst, $CursorPosition)
    return (Complete-Git-Ast -CommandAst $commandAst -CursorPosition $CursorPosition)
}

