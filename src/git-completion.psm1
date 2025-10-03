$ErrorActionPreference = 'Continue'

foreach ($f in (Get-ChildItem -Recurse "$PSScriptRoot")) {
    if ($f.Extension -eq '.ps1') {
        . $f.FullName
    }
}

Export-ModuleMember -Variable 'GitCompletionSettings'

Register-ArgumentCompleter -CommandName gitk -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    return (Complete-Gitk -CommandAst $CommandAst -CursorPosition $CursorPosition)
}

Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    return (Complete-Git -CommandAst $CommandAst -CursorPosition $CursorPosition)
}
