using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe 'Log' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")

        Push-Location $remotePath
        git init --initial-branch=main
        "Initial" | Out-File 'initial.txt'
        "echo hello" | Out-File 'hello.sh'
        git update-index --add --chmod=+x hello.sh
        git add -A
        git commit -m "initial"
        Pop-Location

        Push-Location $rootPath
        git init --initial-branch=main

        git remote add origin "$remotePath"
        git remote add ordinary "$remotePath"
        git remote add grm "$remotePath"

        git config set remotes.default "origin grm"
        git config set remotes.ors "origin ordinary"

        git pull origin main
        git fetch ordinary
        git fetch grm
        mkdir Pwsh
        "echo world" | Out-File 'Pwsh/world.ps1'
        git add -A
        git commit -m "World"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe '<Command>' -ForEach ('log', 'whatchanged' | ForEach-Object { @{Command = $_ } }) {
        It 'ShortOptions' {
            $expected = @(
                @{
                    CompletionText = '-L';
                    ListItemText   = '-L';
                    ResultType     = 'ParameterName';
                    ToolTip        = "trace the evolution of line range <start>,<end> or function :<funcname> in <file>"
                },
                @{
                    CompletionText = '-q';
                    ListItemText   = '-q';
                    ResultType     = 'ParameterName';
                    ToolTip        = "suppress diff output"
                },
                @{
                    CompletionText = '-h';
                    ListItemText   = '-h';
                    ResultType     = 'ParameterName';
                    ToolTip        = "show help";
                }
            )
            "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Context 'In Right' {
                It '<Left>(cursor) <Right>' -ForEach @(
                    @{
                        Left     = @('git', 'log', '--quiet');
                        Right    = @('--');
                        Expected = @(
                            @{
                                CompletionText = '--quiet';
                                ListItemText   = '--quiet';
                                ResultType     = 'ParameterName';
                                ToolTip        = '--quiet';
                            }
                        )
                    },
                    @{
                        Left     = @('git', 'log', '--quiet');
                        Right    = @('-- --all');
                        Expected = @(
                            @{
                                CompletionText = '--quiet';
                                ListItemText   = '--quiet';
                                ResultType     = 'ParameterName';
                                ToolTip        = '--quiet';
                            }
                        )
                    }
                ) {
                    Complete-Git -Words ($Left + $Right) -CurrentIndex ($Left.Length - 1) | 
                    Should -BeCompletion $expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = 'src -- -';
                    Expected = @()
                },
                @{
                    Line     = 'src -- ';
                    Expected = @()
                },
                @{
                    Line     = '-- ';
                    Expected = @()
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--bi';
                    Expected = '--bisect', '--binary' | ForEach-Object { 
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterName';
                            ToolTip        = "$_"
                        }
                    }
                },
                @{
                    Line     = '--no-p';
                    Expected = '--no-prefix', '--no-patch' | ForEach-Object { 
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterName';
                            ToolTip        = "$_"
                        }
                    }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'OptionValue' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--ws-error-highlight d';
                    Expected = 'default' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--ws-error-highlight ';
                    Expected = 'context', 'old', 'new', 'all', 'default' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--ws-error-highlight=d';
                    Expected = 'default' | ForEach-Object {
                        @{
                            CompletionText = "--ws-error-highlight=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--ws-error-highlight=';
                    Expected = 'context', 'old', 'new', 'all', 'default' | ForEach-Object {
                        @{
                            CompletionText = "--ws-error-highlight=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--no-walk=u';
                    Expected = 'unsorted' | ForEach-Object {
                        @{
                            CompletionText = "--no-walk=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--no-walk=';
                    Expected = 'sorted', 'unsorted' | ForEach-Object {
                        @{
                            CompletionText = "--no-walk=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-merges o';
                    Expected = 'off', 'on' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-merges ';
                    Expected = 'off', 'none', 'on', 'first-parent', '1', 'separate', 'm', 'combined', 'c', 'dense-combined', 'cc', 'remerge', 'r' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-merges=o';
                    Expected = 'off', 'on' | ForEach-Object {
                        @{
                            CompletionText = "--diff-merges=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-merges=';
                    Expected = 'off', 'none', 'on', 'first-parent', '1', 'separate', 'm', 'combined', 'c', 'dense-combined', 'cc', 'remerge', 'r' | ForEach-Object {
                        @{
                            CompletionText = "--diff-merges=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--submodule=d';
                    Expected = 'diff' | ForEach-Object {
                        @{
                            CompletionText = "--submodule=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--submodule=';
                    Expected = 'diff', 'log', 'short' | ForEach-Object {
                        @{
                            CompletionText = "--submodule=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-algorithm m';
                    Expected = 'myers', 'minimal' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-algorithm ';
                    Expected = 'myers', 'minimal', 'patience', 'histogram' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-algorithm=m';
                    Expected = 'myers', 'minimal' | ForEach-Object {
                        @{
                            CompletionText = "--diff-algorithm=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--diff-algorithm=';
                    Expected = 'myers', 'minimal', 'patience', 'histogram' | ForEach-Object {
                        @{
                            CompletionText = "--diff-algorithm=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--decorate=f';
                    Expected = 'full' | ForEach-Object {
                        @{
                            CompletionText = "--decorate=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--decorate=';
                    Expected = 'full', 'short', 'no' | ForEach-Object {
                        @{
                            CompletionText = "--decorate=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--date iso';
                    Expected = 'iso8601', 'iso8601-strict' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--date ';
                    Expected = 'relative', 'iso8601', 'iso8601-strict', 'rfc2822', 'short', 'local', 'default', 'human', 'raw', 'unix', 'auto:', 'format:' | ForEach-Object {
                        @{
                            CompletionText = "$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--date=iso';
                    Expected = 'iso8601', 'iso8601-strict' | ForEach-Object {
                        @{
                            CompletionText = "--date=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--date=';
                    Expected = 'relative', 'iso8601', 'iso8601-strict', 'rfc2822', 'short', 'local', 'default', 'human', 'raw', 'unix', 'auto:', 'format:' | ForEach-Object {
                        @{
                            CompletionText = "--date=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--format=m';
                    Expected = 'medium', 'mboxrd' | ForEach-Object {
                        @{
                            CompletionText = "--format=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_"
                        }
                    }
                },
                @{
                    Line     = '--format=';
                    Expected = 'oneline', 'short', 'medium', 'full', 'fuller', 'reference', 'email', 'raw', 'format:', 'tformat:', 'mboxrd' | ForEach-Object {
                        @{
                            CompletionText = "--format=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_"
                        }
                    }
                },
                @{
                    Line     = '--pretty=f';
                    Expected = 'full', 'fuller', 'format:' | ForEach-Object {
                        @{
                            CompletionText = "--pretty=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_"
                        }
                    }
                },
                @{
                    Line     = '--pretty=';
                    Expected = 'oneline', 'short', 'medium', 'full', 'fuller', 'reference', 'email', 'raw', 'format:', 'tformat:', 'mboxrd' | ForEach-Object {
                        @{
                            CompletionText = "--pretty=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_"
                        }
                    }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Revlist' {
            Describe 'RemoteOrRefspec' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/main',
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "$_";
                                ListItemText   = "$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "$_";
                            }
                        }
                    },
                    @{
                        Line     = 'o';
                        Expected = @(
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "$_";
                                ListItemText   = "$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "$_";
                            }
                        }
                    },
                    @{
                        Line     = '^';
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/main',
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "^$_";
                                ListItemText   = "^$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "^$_";
                            }
                        }
                    },
                    @{
                        Line     = '^o';
                        Expected = @(
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "^$_";
                                ListItemText   = "^$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "^$_";
                            }
                        }
                    },
                    @{
                        Line     = 'HEAD...';
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/main',
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "HEAD...$_";
                                ListItemText   = "$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "$_";
                            }
                        }
                    },
                    @{
                        Line     = 'HEAD...o';
                        Expected = @(
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "HEAD...$_";
                                ListItemText   = "$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "$_";
                            }
                        }
                    },
                    @{
                        Line     = 'HEAD..';
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/main',
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "HEAD..$_";
                                ListItemText   = "$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "$_";
                            }
                        }
                    },
                    @{
                        Line     = 'HEAD..o';
                        Expected = @(
                            'ordinary/main',
                            'origin/main'
                        ) | ForEach-Object {
                            @{
                                CompletionText = "HEAD..$_";
                                ListItemText   = "$_";
                                ResultType     = 'ParameterValue';
                                ToolTip        = "$_";
                            }
                        }
                    }
                ) {
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'File' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'brn..main:';
                        Expected = @(
                            'Pwsh/' | ForEach-Object { 
                                @{
                                    File           = $_
                                    CompletionText = "brn..main:$_";
                                    ListItemText   = "$_";
                                    ResultType     = 'ProviderItem';
                                }
                            }) + @(
                            'hello.sh', 'initial.txt' | ForEach-Object { 
                                @{
                                    File           = $_
                                    CompletionText = "brn..main:$_";
                                    ListItemText   = "$_";
                                    ResultType     = 'ProviderItem';
                                }
                            })
                    },
                    @{
                        Line     = 'brn..main:Pwsh/';
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "brn..main:Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = 'main:';
                        Expected = 'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object { 
                            @{
                                File           = $_
                                CompletionText = "main:$_";
                                ListItemText   = "$_";
                                ResultType     = 'ProviderItem';
                            }
                        }
                    },
                    @{
                        Line     = 'main:Pws';
                        Expected = 'Pwsh/' | ForEach-Object { 
                            @{
                                File           = $_
                                CompletionText = "main:$_";
                                ListItemText   = "$_";
                                ResultType     = 'ProviderItem';
                            }
                        }
                    },
                    @{
                        Line     = 'main:Pwsh/';
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "main:Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = 'main:Pwsh/wo';
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "main:Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = 'main:./Pwsh/';
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "main:./Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = 'main:./Pwsh/wo';
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "main:./Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    }
                ) {
                    foreach ($e in $expected) {
                        $e.ToolTip = (Resolve-Path $e.File).Path.TrimEnd([Path]::AltDirectorySeparatorChar, [Path]::DirectorySeparatorChar)
                    }
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
}