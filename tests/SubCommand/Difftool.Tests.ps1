using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe 'Difftool' {
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
                CompletionText = '-d';
                ListItemText   = '-d';
                ResultType     = 'ParameterName';
                ToolTip        = "perform a full-directory diff";
            },
            @{
                CompletionText = '-g';
                ListItemText   = '-g';
                ResultType     = 'ParameterName';
                ToolTip        = 'use `diff.guitool` instead of `diff.tool`';
            },
            @{
                CompletionText = '-t';
                ListItemText   = '-t';
                ResultType     = 'ParameterName';
                ToolTip        = "use the specified diff tool";
            },
            @{
                CompletionText = '-x';
                ListItemText   = '-x';
                ResultType     = 'ParameterName';
                ToolTip        = "specify a custom command for viewing diffs";
            },
            @{
                CompletionText = '-y';
                ListItemText   = '-y';
                ResultType     = 'ParameterName';
                ToolTip        = "do not prompt before launching a diff tool";
            },
            @{
                CompletionText = '-h';
                ListItemText   = '-h';
                ResultType     = 'ParameterName';
                ToolTip        = "show help";
            }
        )
        "git difftool -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--t';
                Expected = @(
                    @{
                        CompletionText = "--theirs";
                        ListItemText   = "--theirs";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--theirs"
                    },
                    @{
                        CompletionText = "--text";
                        ListItemText   = "--text";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--text"
                    },
                    @{
                        CompletionText = "--textconv";
                        ListItemText   = "--textconv";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--textconv"
                    },
                    @{
                        CompletionText = "--tool=";
                        ListItemText   = "--tool=";
                        ResultType     = 'ParameterName';
                        ToolTip        = "use the specified diff tool"
                    },
                    @{
                        CompletionText = "--tool-help";
                        ListItemText   = "--tool-help";
                        ResultType     = 'ParameterName';
                        ToolTip        = 'print a list of diff tools that may be used with `--tool`'
                    },
                    @{
                        CompletionText = "--trust-exit-code";
                        ListItemText   = "--trust-exit-code";
                        ResultType     = 'ParameterName';
                        ToolTip        = "make 'git-difftool' exit when an invoked diff tool returns a non-zero exit code"
                    }
                )
            },
            @{
                Line     = '--ind';
                Expected = @(
                    @{
                        CompletionText = "--indent-heuristic";
                        ListItemText   = "--indent-heuristic";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--indent-heuristic"
                    },
                    @{
                        CompletionText = "--index";
                        ListItemText   = "--index";
                        ResultType     = 'ParameterName';
                        ToolTip        = "opposite of --no-index"
                    }
                )
            },
            @{
                Line     = '--no-t';
                Expected = @(
                    @{
                        CompletionText = "--no-textconv";
                        ListItemText   = "--no-textconv";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--no-textconv"
                    },
                    @{
                        CompletionText = "--no-tool";
                        ListItemText   = "--no-tool";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] use the specified diff tool"
                    },
                    @{
                        CompletionText = "--no-tool-help";
                        ListItemText   = "--no-tool-help";
                        ResultType     = 'ParameterName';
                        ToolTip        = '[NO] print a list of diff tools that may be used with `--tool`'
                    },
                    @{
                        CompletionText = "--no-trust-exit-code";
                        ListItemText   = "--no-trust-exit-code";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] make 'git-difftool' exit when an invoked diff tool returns a non-zero exit code"
                    }
                )
            }
        ) {
            "git difftool $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
        It 'No' {
            $expected = @(
                @{
                    CompletionText = "--no-";
                    ListItemText   = "--no-...";
                    ResultType     = 'Text';
                    ToolTip        = "--no-..."
                }
            )
            "git difftool --no" | Complete-FromLine | Select-Object -Last 1 | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--tool=k';
                Expected = 'kdiff3', 'kompare' | ForEach-Object {
                    @{
                        CompletionText = "--tool=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--tool=v';
                Expected = 'vimdiff' | ForEach-Object {
                    @{
                        CompletionText = "--tool=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--tool k';
                Expected = 'kdiff3', 'kompare' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--tool v';
                Expected = 'vimdiff' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            }
        ) {
            "git difftool $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                "git difftool $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                "git difftool $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}