using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    It 'ShortOptions' {
        $expected = @(
            @{
                CompletionText = '-4';
                ListItemText   = '-4';
                ResultType     = 'ParameterName';
                ToolTip        = "use IPv4 addresses only";
            },
            @{
                CompletionText = '-6';
                ListItemText   = '-6';
                ResultType     = 'ParameterName';
                ToolTip        = "use IPv6 addresses only";
            },
            @{
                CompletionText = '-a';
                ListItemText   = '-a';
                ResultType     = 'ParameterName';
                ToolTip        = "append to .git/FETCH_HEAD instead of overwriting";
            },
            @{
                CompletionText = '-f';
                ListItemText   = '-f';
                ResultType     = 'ParameterName';
                ToolTip        = "force overwrite of local branch";
            },
            @{
                CompletionText = '-j';
                ListItemText   = '-j';
                ResultType     = 'ParameterName';
                ToolTip        = "number of submodules pulled in parallel";
            },
            @{
                CompletionText = '-k';
                ListItemText   = '-k';
                ResultType     = 'ParameterName';
                ToolTip        = "keep downloaded pack";
            },
            @{
                CompletionText = '-n';
                ListItemText   = '-n';
                ResultType     = 'ParameterName';
                ToolTip        = "do not show a diffstat at the end of the merge";
            },
            @{
                CompletionText = '-o';
                ListItemText   = '-o';
                ResultType     = 'ParameterName';
                ToolTip        = "option to transmit";
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "prune remote-tracking branches no longer on remote";
            },
            @{
                CompletionText = '-q';
                ListItemText   = '-q';
                ResultType     = 'ParameterName';
                ToolTip        = "be more quiet";
            },
            @{
                CompletionText = '-r';
                ListItemText   = '-r';
                ResultType     = 'ParameterName';
                ToolTip        = "incorporate changes by rebasing rather than merging";
            },
            @{
                CompletionText = '-s';
                ListItemText   = '-s';
                ResultType     = 'ParameterName';
                ToolTip        = "merge strategy to use";
            },
            @{
                CompletionText = '-S';
                ListItemText   = '-S';
                ResultType     = 'ParameterName';
                ToolTip        = "GPG sign commit";
            },
            @{
                CompletionText = '-t';
                ListItemText   = '-t';
                ResultType     = 'ParameterName';
                ToolTip        = "fetch all tags and associated objects";
            },
            @{
                CompletionText = '-v';
                ListItemText   = '-v';
                ResultType     = 'ParameterName';
                ToolTip        = "be more verbose";
            },
            @{
                CompletionText = '-X';
                ListItemText   = '-X';
                ResultType     = 'ParameterName';
                ToolTip        = "option for selected merge strategy";
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

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--ip';
                Expected = @(
                    @{
                        CompletionText = '--ipv4';
                        ListItemText   = '--ipv4';
                        ResultType     = 'ParameterName';
                        ToolTip        = "use IPv4 addresses only";
                    },
                    @{
                        CompletionText = '--ipv6';
                        ListItemText   = '--ipv6';
                        ResultType     = 'ParameterName';
                        ToolTip        = "use IPv6 addresses only";
                    }
                )
            },
            @{
                Line     = '--no-ip';
                Expected = @(
                    @{
                        CompletionText = '--no-ipv4';
                        ListItemText   = '--no-ipv4';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] use IPv4 addresses only";
                    },
                    @{
                        CompletionText = '--no-ipv6';
                        ListItemText   = '--no-ipv6';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] use IPv6 addresses only";
                    }
                )
            },
            @{
                Line     = '--no';
                Expected = @(
                    @{
                        CompletionText = '--no-verbose';
                        ListItemText   = '--no-verbose';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] be more verbose";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                        ToolTip        = "--no-...";
                    }
                )
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        Describe 'CompleteStrategy' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '-s ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
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
                    Line     = '-s o';
                    Expected = @(
                        'octopus',
                        'ours'
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
                    Line     = '--strategy ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
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
                    Line     = '--strategy o';
                    Expected = @(
                        'octopus',
                        'ours'
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
                    Line     = '--strategy=o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ForEach-Object {
                        @{
                            CompletionText = "--strategy=$_";
                            ListItemText   = "$_";
                            ResultType     = 'ParameterValue';
                            ToolTip        = "$_";
                        }
                    }
                },
                @{
                    Line     = '--strategy-option ';
                    Expected = @(
                        'ours',
                        'theirs',
                        'subtree',
                        'subtree=',
                        'patience',
                        'histogram',
                        'diff-algorithm=',
                        'ignore-space-change',
                        'ignore-all-space',
                        'ignore-space-at-eol',
                        'renormalize',
                        'no-renormalize',
                        'no-renames',
                        'find-renames',
                        'find-renames=',
                        'rename-threshold='
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
                    Line     = '--strategy-option r';
                    Expected = @(
                        'renormalize',
                        'rename-threshold='
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
                    Line     = '--strategy-option=r';
                    Expected = @(
                        'renormalize',
                        'rename-threshold='
                    ) | ForEach-Object {
                        @{
                            CompletionText = "--strategy-option=$_";
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

        It '<Line>' -ForEach @(
            @{
                Line     = '--recurse-submodules ';
                Expected = @(
                    @{
                        CompletionText = 'yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    },
                    @{
                        CompletionText = 'on-demand';
                        ListItemText   = 'on-demand';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "on-demand";
                    },
                    @{
                        CompletionText = 'no';
                        ListItemText   = 'no';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "no";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules y';
                Expected = @(
                    @{
                        CompletionText = 'yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = @(
                    @{
                        CompletionText = '--recurse-submodules=yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    },
                    @{
                        CompletionText = '--recurse-submodules=on-demand';
                        ListItemText   = 'on-demand';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "on-demand";
                    },
                    @{
                        CompletionText = '--recurse-submodules=no';
                        ListItemText   = 'no';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "no";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules=y';
                Expected = @(
                    @{
                        CompletionText = '--recurse-submodules=yes';
                        ListItemText   = 'yes';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "yes";
                    }
                )
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'RemoteOrRefspec' {
        It '<Line>' -ForEach @(
            @{
                Line     = 'origin ';
                Expected = @(
                    'HEAD',
                    'main'
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
                Line     = 'origin m';
                Expected = @(
                    'main'
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
                Line     = 'origin +';
                Expected = @(
                    'HEAD',
                    'main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "+$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin +m';
                Expected = @(
                    'main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "+$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin left:';
                Expected = @(
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/main',
                    'ordinary/main',
                    'origin/main',
                    'initial'
                ) | ForEach-Object {
                    @{
                        CompletionText = "left:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin left:m';
                Expected = @(
                    'main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "left:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'or';
                Expected = @(
                    'ordinary',
                    'origin'
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
                Line     = '';
                Expected = @(
                    'grm',
                    'ordinary',
                    'origin'
                ) | ForEach-Object {
                    @{
                        CompletionText = "$_";
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
}
