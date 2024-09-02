$ErrorActionPreference = 'Continue'

Get-ChildItem -Recurse "$PSScriptRoot" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }

Export-ModuleMember -Variable 'GitCompletionSettings'

Register-ArgumentCompleter -CommandName gitk -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    $CommandAst>"$PSScriptRoot/../debug.log"
    return (Complete-Gitk -CommandAst $CommandAst -CursorPosition $CursorPosition)
}

Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    return (Complete-Git -CommandAst $CommandAst -CursorPosition $CursorPosition)
}
