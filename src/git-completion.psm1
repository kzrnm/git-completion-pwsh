$ErrorActionPreference = 'Continue'

Get-ChildItem -Recurse "$PSScriptRoot" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }

Export-ModuleMember -Variable 'GitCompletionSettings'

Register-ArgumentCompleter -CommandName gitk -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)

    $words, $CurrentIndex = buildWords $wordToComplete $CommandAst $CursorPosition 'gitk'
    return (Complete-Gitk -Words $words -CurrentIndex $CurrentIndex)
}

Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)

    $words, $CurrentIndex = buildWords $wordToComplete $CommandAst $CursorPosition 'git'
    return (Complete-Git -Words $words -CurrentIndex $CurrentIndex)
}
