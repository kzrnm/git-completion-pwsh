using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'UseRemote' -Skip:$SkipHeavyTest {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")

        Push-Location $remotePath
        git init --initial-branch=main
        git commit -m "initial" --allow-empty
        Pop-Location

        Push-Location $rootPath
        git init --initial-branch=main

        git remote add origin "$remotePath"
        git remote add ordinary "$remotePath"
        git remote add grm "$remotePath"

        git pull origin main
        git fetch ordinary
        git fetch grm
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'Push' {
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
            "git push -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--force-with-lease=';
                    Expected = @(
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/main',
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
                "git push $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrRefspec' {
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
                    "git push $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Delete' {
                It '<Line>' -ForEach @(
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
                    "git push $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
            It '<Line>' -ForEach @(
                @{
                    Line     = 'origin ';
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
                    Line     = 'origin +';
                    Expected = @(
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/main',
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
                }
            ) {
                "git push $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'Fetch' {
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
                    ToolTip        = "force overwrite of local reference";
                },
                @{
                    CompletionText = '-j';
                    ListItemText   = '-j';
                    ResultType     = 'ParameterName';
                    ToolTip        = "number of submodules fetched in parallel";
                },
                @{
                    CompletionText = '-k';
                    ListItemText   = '-k';
                    ResultType     = 'ParameterName';
                    ToolTip        = "keep downloaded pack";
                },
                @{
                    CompletionText = '-m';
                    ListItemText   = '-m';
                    ResultType     = 'ParameterName';
                    ToolTip        = "fetch from multiple remotes";
                },
                @{
                    CompletionText = '-n';
                    ListItemText   = '-n';
                    ResultType     = 'ParameterName';
                    ToolTip        = "do not fetch all tags (--no-tags)";
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
                    CompletionText = '-P';
                    ListItemText   = '-P';
                    ResultType     = 'ParameterName';
                    ToolTip        = "prune local tags no longer on remote and clobber changed tags";
                },
                @{
                    CompletionText = '-q';
                    ListItemText   = '-q';
                    ResultType     = 'ParameterName';
                    ToolTip        = "be more quiet";
                },
                @{
                    CompletionText = '-t';
                    ListItemText   = '-t';
                    ResultType     = 'ParameterName';
                    ToolTip        = "fetch all tags and associated objects";
                },
                @{
                    CompletionText = '-u';
                    ListItemText   = '-u';
                    ResultType     = 'ParameterName';
                    ToolTip        = "allow updating of HEAD ref";
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
            "git fetch -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
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
                },
                @{
                    Line     = '--f';
                    Expected = @(
                        @{
                            CompletionText = '--force';
                            ListItemText   = '--force';
                            ResultType     = 'ParameterName';
                            ToolTip        = "force overwrite of local reference";
                        },
                        @{
                            CompletionText = '--filter=';
                            ListItemText   = '--filter=';
                            ResultType     = 'ParameterName';
                            ToolTip        = "object filtering";
                        }
                    )
                },
                @{
                    Line     = '--no-f';
                    Expected = @(
                        @{
                            CompletionText = '--no-force';
                            ListItemText   = '--no-force';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] force overwrite of local reference";
                        },
                        @{
                            CompletionText = '--no-filter';
                            ListItemText   = '--no-filter';
                            ResultType     = 'ParameterName';
                            ToolTip        = "[NO] object filtering";
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
                "git fetch $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrRefspec' {
            Describe 'SpecificOptions' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--multiple ';
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
                        Line     = '--multiple or';
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
                        Line     = '--all ';
                        Expected = @()
                    }
                ) {
                    "git fetch $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = 'origin ';
                    Expected = @(
                        'HEAD:HEAD',
                        'main:main'
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
                        'main:main'
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
                        'HEAD:HEAD',
                        'main:main'
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
                        'main:main'
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
                        'origin/main'
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
                "git fetch $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}