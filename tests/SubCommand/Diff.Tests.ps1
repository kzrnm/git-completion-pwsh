using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'Diff' {
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

    It 'ShortOptions' {
        $expected = @(
            @{
                CompletionText = '-a';
                ListItemText   = '-a';
                ResultType     = 'ParameterName';
                ToolTip        = "treat all files as text.";
            },
            @{
                CompletionText = '-B';
                ListItemText   = '-B';
                ResultType     = 'ParameterName';
                ToolTip        = "detect complete rewrites.";
            },
            @{
                CompletionText = '-C';
                ListItemText   = '-C';
                ResultType     = 'ParameterName';
                ToolTip        = "detect copies.";
            },
            @{
                CompletionText = '-l';
                ListItemText   = '-l';
                ResultType     = 'ParameterName';
                ToolTip        = "limit rename attempts up to <n> paths.";
            },
            @{
                CompletionText = '-M';
                ListItemText   = '-M';
                ResultType     = 'ParameterName';
                ToolTip        = "detect renames.";
            },
            @{
                CompletionText = '-O';
                ListItemText   = '-O';
                ResultType     = 'ParameterName';
                ToolTip        = "reorder diffs according to the <file>.";
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "output patch format.";
            },
            @{
                CompletionText = '-R';
                ListItemText   = '-R';
                ResultType     = 'ParameterName';
                ToolTip        = "swap input file pairs.";
            },
            @{
                CompletionText = '-S';
                ListItemText   = '-S';
                ResultType     = 'ParameterName';
                ToolTip        = "find filepair whose only one side contains the string.";
            },
            @{
                CompletionText = '-u';
                ListItemText   = '-u';
                ResultType     = 'ParameterName';
                ToolTip        = "synonym for -p.";
            },
            @{
                CompletionText = '-z';
                ListItemText   = '-z';
                ResultType     = 'ParameterName';
                ToolTip        = "output diff-raw with lines terminated with NUL.";
            },
            @{
                CompletionText = '-h';
                ListItemText   = '-h';
                ResultType     = 'ParameterName';
                ToolTip        = "show help";
            }
        )
        "git diff -" | Complete-FromLine | Should -BeCompletion $expected
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
            "git diff $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--b';
                Expected = '--base', '--binary', '--break-rewrites' | ForEach-Object { 
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
            "git diff $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--color-moved-ws i';
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved-ws ';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved-ws=i';
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ForEach-Object {
                    @{
                        CompletionText = "--color-moved-ws=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved-ws=';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ForEach-Object {
                    @{
                        CompletionText = "--color-moved-ws=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved=d';
                Expected = 'default', 'dimmed-zebra'  | ForEach-Object {
                    @{
                        CompletionText = "--color-moved=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved=';
                Expected = 'no', 'default', 'plain', 'blocks', 'zebra', 'dimmed-zebra' | ForEach-Object {
                    @{
                        CompletionText = "--color-moved=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
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
            }
        ) {
            "git diff $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                "git diff $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                "git diff $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}