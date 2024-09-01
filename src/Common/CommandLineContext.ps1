using namespace System.IO;

class CommandLineContext {
    [string[]] $Words
    [DirectoryInfo] $gitDir
    [string] $Command
    [int] $CommandIndex
    [string[]] $gitCArgs

    [int] $CurrentIndex = -1
    [int] $SubcommandLikeIndex = -1
    [int] $DoubledashIndex = -1

    CommandLineContext (
        [string[]] $Words,
        [int] $CurrentIndex
    ) {
        $this.Words = $Words
        $this.CurrentIndex = $CurrentIndex

        $this.gitDir = $null
        $this.gitCArgs = @()
        $this.Command = ''

        :globalflag for ($i = 1; $i -lt $Words.Length; $i++) {
            if ($i -eq $CurrentIndex) { continue }
            $s = $Words[$i]
            switch -Wildcard -CaseSensitive ($s) {
                '--' {
                    $this.DoubledashIndex = $i
                    break globalflag
                }
                '--git-dir=*' {
                    $this.gitDir = [DirectoryInfo]::new($s.Substring('--git-dir='.Length))
                    continue
                }
                '--git-dir' {
                    ++$i
                    if (($i -lt $this.Words.Count) -and ($i -ne $CurrentIndex)) {
                        $this.gitDir = [DirectoryInfo]::new($this.Words[$i])
                    }
                    continue
                }
                '--bare' {
                    $this.gitDir = [DirectoryInfo]::new('.')
                    continue
                }
                '--help' {
                    if ($i -lt $CurrentIndex) {
                        $this.Command = 'help'
                        $this.CommandIndex = $i
                    }
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
                    if ($i -lt $CurrentIndex) {
                        $this.Command = $s
                        $this.CommandIndex = $i
                    }
                    break globalflag
                }
            }
        }

        if ($this.DoubledashIndex -ge 0) { return }
        if ($this.CommandIndex -lt 0) { return }

        :subcommand for ($i++; $i -lt $CurrentIndex; $i++) {
            $s = $Words[$i]
            switch -Wildcard -CaseSensitive ($s) {
                '--' {
                    $this.DoubledashIndex = $i
                    break subcommand
                }
                '-*' { continue }
                default {
                    $this.SubcommandLikeIndex = $i
                    break subcommand
                }
            }
        }

        if ($this.DoubledashIndex -ge 0) { return }
        for ($i++; $i -lt $Words.Length; $i++) {
            if ($i -eq $CurrentIndex) { continue }
            if ($Words[$i] -eq '--') {
                $this.DoubledashIndex = $i
                break
            }
        }

        if ($this.DoubledashIndex -ge 0) { return }
        $this.DoubledashIndex = $Words.Length
    }

    [string] Subcommand() {
        if ($this.SubcommandLikeIndex -lt 0) { 
            return $null
        }
        return $this.Words[$this.SubcommandLikeIndex]
    }

    [string] SubcommandWithoutGlobalOption() {
        if ($this.SubcommandLikeIndex -ne $this.CommandIndex + 1) { 
            return $null
        }
        return $this.Words[$this.SubcommandLikeIndex]
    }

    [string] CurrentWord() { return $this.Words[$this.CurrentIndex] }
    [string] PreviousWord() { return $this.Words[$this.CurrentIndex - 1] }

    # __git_has_doubledash
    [bool] HasDoubledash() {
        return $this.DoubledashIndex -lt $this.CurrentIndex
    }
}