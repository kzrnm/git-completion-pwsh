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

$gitNames = (@('git') + (Get-Alias | Where-Object ResolvedCommandName -In git,git.exe | ForEach-Object Name)) | Select-Object -Unique
Register-ArgumentCompleter -CommandName $gitNames -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    return (Complete-Git -CommandAst $CommandAst -CursorPosition $CursorPosition)
}
