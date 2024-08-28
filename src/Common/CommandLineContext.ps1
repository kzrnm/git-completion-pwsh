using namespace System.IO;

class CommandLineContext {
    [string[]] $Words
    [DirectoryInfo] $gitDir
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
        $this.commandIndex = -1

        :globalflag for ($i = 1; ($i + 1) -lt $this.Words.Length; $i++) {
            $s = $this.Words[$i]
            switch -Wildcard -CaseSensitive ($s) {
                '--git-dir=*' {
                    $this.gitDir = [DirectoryInfo]::new($s.Substring('--git-dir='.Length))
                    continue
                }
                '--git-dir' {
                    if (++$i -lt $this.Words.Count) {
                        $this.gitDir = [DirectoryInfo]::new($this.Words[$i])
                    }
                    continue
                }
                '--bare' {
                    $this.gitDir = [DirectoryInfo]::new('.')
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

        if ((0 -lt $i) -and (($i + 1) -lt $this.Words.Length)) {
            return $this.Words[$i]
        }
        return $null
    }

    [string] CurrentWord() { return $this.Words[-1] }
    [string] PreviousWord() { return $this.Words[-2] }

    [string[]] WordsWithoutLeadingOptions() {
        $l = [System.Collections.Generic.List[string]]::new($this.Words.Length)
        for ($i = $this.commandIndex + 1; $i -lt $this.Words.Length; $i++) {
            $w = $this.Words[$i]
            if ($w.StartsWith('-') -and ($l.Count -eq 0)) {
                # Do nothing
            }
            else {
                $l.Add($w)
            }
        }
        return $l.ToArray()
    }
}