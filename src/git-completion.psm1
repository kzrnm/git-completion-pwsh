$ErrorActionPreference = 'Continue'

Get-ChildItem -Recurse "$PSScriptRoot" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }

Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)

    $ws = [System.Collections.Generic.List[string]]::new($CommandAst.CommandElements.Count + 2)
    $ws.Add('git')

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $extent = $CommandAst.CommandElements[$i].Extent
        if ($CursorPosition -lt $extent.StartOffset) {
            $ws.Add('')
            break
        }

        if ($CursorPosition -lt $extent.EndOffset) {
            $ws.Add($extent.Text.Substring(0, $CursorPosition - $extent.StartOffset))
            break
        }
        else {
            $ws.Add($extent.Text)
            if ($CursorPosition -eq $extent.EndOffset) { break }
        }
    }

    if ($CommandAst.CommandElements.Count -eq $i) {
        $ws.Add('')
    }

    return (
        Complete-Git -Words $ws.ToArray() 
    )
}
