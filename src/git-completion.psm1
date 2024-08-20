$ErrorActionPreference = 'Continue'

Get-ChildItem -Recurse "$PSScriptRoot" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    
    $ws = [System.Collections.Generic.List[string]]::new($CommandAst.CommandElements.Count)
    $ws.Add('git')

    $pr = $CommandAst.CommandElements[-1]
    $cr = ''

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $ws.Add($commandAst.CommandElements[$i].Extent.Text)
        $extent = $CommandAst.CommandElements[$i].Extent
        if ($CursorPosition -lt $extent.StartOffset) {
            # The cursor is within whitespace between the previous and current words.
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            break
        }
        elseif ($CursorPosition -le $extent.EndOffset) {
            $cr = $extent.Text
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            break
        }
    }

    if ($CommandAst.CommandElements.Count -eq $i) {
        $ws.Add('')
        $CurrentWord = ''
        $PreviousWord = $cr
    }
    else {
        $CurrentWord = $cr
        $PreviousWord = $pr
    }

    return (
        Complete-Git `
            -CursorPosition $CursorPosition `
            -Words $ws.ToArray() `
            -CurrentWord $CurrentWord `
            -PreviousWord $PreviousWord `
    )
}
