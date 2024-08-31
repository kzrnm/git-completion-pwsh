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
                CompletionText = '-d';
                ListItemText   = '-d';
                ResultType     = 'ParameterName';
                ToolTip        = "delete refs";
            },
            @{
                CompletionText = '-f';
                ListItemText   = '-f';
                ResultType     = 'ParameterName';
                ToolTip        = "force updates";
            },
            @{
                CompletionText = '-n';
                ListItemText   = '-n';
                ResultType     = 'ParameterName';
                ToolTip        = "dry run";
            },
            @{
                CompletionText = '-o';
                ListItemText   = '-o';
                ResultType     = 'ParameterName';
                ToolTip        = "option to transmit";
            },
            @{
                CompletionText = '-q';
                ListItemText   = '-q';
                ResultType     = 'ParameterName';
                ToolTip        = "be more quiet";
            },
            @{
                CompletionText = '-u';
                ListItemText   = '-u';
                ResultType     = 'ParameterName';
                ToolTip        = "set upstream for git pull/status";
            },
            @{
                CompletionText = '-v';
                ListItemText   = '-v';
                ResultType     = 'ParameterName';
                ToolTip        = "be more verbose";
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
                Line     = '--re';
                Expected = @(
                    @{
                        CompletionText = '--repo=';
                        ListItemText   = '--repo=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "repository";
                    },
                    @{
                        CompletionText = '--recurse-submodules=';
                        ListItemText   = '--recurse-submodules=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "control recursive pushing of submodules";
                    },
                    @{
                        CompletionText = '--receive-pack=';
                        ListItemText   = '--receive-pack=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "receive pack program";
                    }
                )
            },
            @{
                Line     = '--re';
                Expected = @(
                    @{
                        CompletionText = '--repo=';
                        ListItemText   = '--repo=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "repository";
                    },
                    @{
                        CompletionText = '--recurse-submodules=';
                        ListItemText   = '--recurse-submodules=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "control recursive pushing of submodules";
                    },
                    @{
                        CompletionText = '--receive-pack=';
                        ListItemText   = '--receive-pack=';
                        ResultType     = 'ParameterName';
                        ToolTip        = "receive pack program";
                    }
                )
            },
            @{
                Line     = '--no-re';
                Expected = @(
                    @{
                        CompletionText = '--no-repo';
                        ListItemText   = '--no-repo';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] repository";
                    },
                    @{
                        CompletionText = '--no-recurse-submodules';
                        ListItemText   = '--no-recurse-submodules';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] control recursive pushing of submodules";
                    },
                    @{
                        CompletionText = '--no-receive-pack';
                        ListItemText   = '--no-receive-pack';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] receive pack program";
                    }
                )
            },
            @{
                Line     = '--n';
                Expected = @(
                    @{
                        CompletionText = '--no-verify';
                        ListItemText   = '--no-verify';
                        ResultType     = 'ParameterName';
                        ToolTip        = "bypass pre-push hook";
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
        Describe 'noCompleteRefspec' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--mirror ';
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
                },
                @{
                    Line     = '--mirror or';
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
                    Line     = '--mirror origin ';
                    Expected = @()
                },
                @{
                    Line     = '--all ';
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
                },
                @{
                    Line     = '--all or';
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
                    Line     = '--all origin ';
                    Expected = @()
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--force-with-lease=';
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
                        CompletionText = "--force-with-lease=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--force-with-lease=or';
                Expected = @(
                    'ordinary/main',
                    'origin/main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "--force-with-lease=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--force-with-lease=ma:';
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
                        CompletionText = "--force-with-lease=ma:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--force-with-lease=ma:or';
                Expected = @(
                    'ordinary/main',
                    'origin/main'
                ) | ForEach-Object {
                    @{
                        CompletionText = "--force-with-lease=ma:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--recurse-submodules ';
                Expected = @(
                    @{
                        CompletionText = 'check';
                        ListItemText   = 'check';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "check";
                    },
                    @{
                        CompletionText = 'on-demand';
                        ListItemText   = 'on-demand';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "on-demand";
                    },
                    @{
                        CompletionText = 'only';
                        ListItemText   = 'only';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "only";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules c';
                Expected = @(
                    @{
                        CompletionText = 'check';
                        ListItemText   = 'check';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "check";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = @(
                    @{
                        CompletionText = '--recurse-submodules=check';
                        ListItemText   = 'check';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "check";
                    },
                    @{
                        CompletionText = '--recurse-submodules=on-demand';
                        ListItemText   = 'on-demand';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "on-demand";
                    },
                    @{
                        CompletionText = '--recurse-submodules=only';
                        ListItemText   = 'only';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "only";
                    }
                )
            },
            @{
                Line     = '--recurse-submodules=c';
                Expected = @(
                    @{
                        CompletionText = '--recurse-submodules=check';
                        ListItemText   = 'check';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "check";
                    }
                )
            },
            @{
                Line     = '--repo=';
                Expected = @(
                    @{
                        CompletionText = '--repo=grm';
                        ListItemText   = 'grm';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "grm";
                    },
                    @{
                        CompletionText = '--repo=ordinary';
                        ListItemText   = 'ordinary';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = '--repo=origin';
                        ListItemText   = 'origin';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "origin";
                    }
                )
            },
            @{
                Line     = '--repo=or';
                Expected = @(
                    @{
                        CompletionText = '--repo=ordinary';
                        ListItemText   = 'ordinary';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = '--repo=origin';
                        ListItemText   = 'origin';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "origin";
                    }
                )
            },
            @{
                Line     = '--repo ';
                Expected = @(
                    @{
                        CompletionText = 'grm';
                        ListItemText   = 'grm';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "grm";
                    },
                    @{
                        CompletionText = 'ordinary';
                        ListItemText   = 'ordinary';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = 'origin';
                        ListItemText   = 'origin';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "origin";
                    }
                )
            },
            @{
                Line     = '--repo or';
                Expected = @(
                    @{
                        CompletionText = 'ordinary';
                        ListItemText   = 'ordinary';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = 'origin';
                        ListItemText   = 'origin';
                        ResultType     = 'ParameterValue';
                        ToolTip        = "origin";
                    }
                )
            },
            @{
                Line     = '--delete ';
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
            },
            @{
                Line     = '-d ';
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

    Describe 'RemoteOrRefspec' {
        It '<Line>' -ForEach @(
            @{
                Line     = 'origin ';
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
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin o';
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
                Line     = 'origin ^';
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
                        CompletionText = "^$_";
                        ListItemText   = "^$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "^$_";
                    }
                }
            },
            @{
                Line     = 'origin ^o';
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
                Line     = 'origin +';
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
                        CompletionText = "+$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = 'origin +o';
                Expected = @(
                    'ordinary/main',
                    'origin/main'
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
            },
            @{
                Line     = 'origin refs';
                Expected = @(
                    'refs/heads/main',
                    'refs/remotes/grm/main',
                    'refs/remotes/ordinary/main',
                    'refs/remotes/origin/main',
                    'refs/tags/initial'
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
                Line     = 'origin refs/h';
                Expected = @(
                    'refs/heads/main'
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

    Describe 'Middle' {
        It '<Left>(cursor) <Right>' -ForEach @(
            @{
                Left     = @('git', 'push', 'o');
                Right    = @('main');
                Expected = @(
                    @{
                        CompletionText = 'ordinary';
                        ListItemText   = 'ordinary';
                        ResultType     = 'ParameterValue';
                        ToolTip        = 'ordinary';
                    },
                    @{
                        CompletionText = 'origin';
                        ListItemText   = 'origin';
                        ResultType     = 'ParameterValue';
                        ToolTip        = 'origin';
                    }
                )
            }
        ) {
            Complete-Git -Words ($Left + $Right) -CurrentIndex ($Left.Length - 1) | 
            Should -BeCompletion $expected
        }
    }
}
