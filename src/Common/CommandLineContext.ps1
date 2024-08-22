class CommandLineContext {
    [string[]] $Words
    [System.IO.DirectoryInfo] $gitDir
    [string] $command
    [int] $commandIndex
    [string[]] $gitCArgs


    CommandLineContext (
        [string[]] $Words
    ) {
        $this.Words = $Words

        $this.gitDir = $null
        $this.gitCArgs = @()
        $this.command = ''
        $this.commandIndex = 0

        :globalflag for ($i = 1; $i -lt ($this.Words.Length - 1); $i++) {
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

    [string] Subcommand() {
        $i = $this.commandIndex + 1

        if ($i -lt ($this.Words.Length - 1)) {
            return $this.Words[$i]
        }
        return $null
    }

    [string] CurrentWord() { return $this.Words[-1] }
    [string] PreviousWord() { return $this.Words[-2] }
}