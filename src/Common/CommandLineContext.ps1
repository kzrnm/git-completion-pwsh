class CommandLineContext {
    [int] $CursorPosition
    [string[]] $Words
    [int] $WordPosition
    [string] $CurrentWord
    [string] $PreviousWord
    [System.IO.DirectoryInfo] $gitDir
    [string] $command
    [int] $commandIndex
    [string[]] $gitCArgs


    CommandLineContext (
        [int] $CursorPosition,
        [string[]] $Words,
        [int] $WordPosition,
        [string] $CurrentWord,
        [string] $PreviousWord
    ) {
        $this.CursorPosition = $CursorPosition
        $this.Words = $Words
        $this.WordPosition = $WordPosition
        $this.CurrentWord = $CurrentWord
        $this.PreviousWord = $PreviousWord

        $this.gitDir = $null
        $this.gitCArgs = @()
        $this.command = ''
        $this.commandIndex = 0

        :globalflag for ($i = 1; $i -lt $this.WordPosition; $i++) {
            $s = $this.Words[$i]
            switch -Wildcard -CaseSensitive ($s) {
                '--git-dir=*' {
                    $this.gitDir = [System.IO.DirectoryInfo]::new($s.Substring('--git-dir='.Length))
                    continue
                }
                '--git-dir' {
                    if (++$i -lt $this.Words.Count) {
                        $this.gitDir = [System.IO.DirectoryInfo]::new($this.Words[$i])
                    }
                    continue
                }
                '--bare' {
                    $this.gitDir = [System.IO.DirectoryInfo]::new('.')
                    continue
                }
                '--help' {
                    $this.command = 'help'
                    break globalflag
                }
                { $_ -cin @('-c', '--work-tree', '--namespace') } {
                    ++$i
                    continue
                }
                '-C' {
                    $this.gitCArgs += @('-C', $this.Words[++$i])
                    continue
                }
                '-*' {
                    continue
                }
                default {
                    $this.command = $s
                    $this.commandIndex = $i
                    break globalflag
                }
            }
        }
    }
}