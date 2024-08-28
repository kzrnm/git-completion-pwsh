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

        git config set remotes.default "origin grm"
        git config set remotes.ors "origin ordinary"

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
                    "git push $Line" | Complete-FromLine | Should -BeCompletion $expected
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

        Describe 'OptionValue' {
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

        Describe 'RemoteOrRefspec' {
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

    Describe 'Pull' {
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
            "git pull -" | Complete-FromLine | Should -BeCompletion $expected
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
                "git pull $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                    "git pull $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                "git pull $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                "git pull $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'Remote' {
        Describe '_' {
            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-v';
                        ListItemText   = '-v';
                        ResultType     = 'ParameterName';
                        ToolTip        = "be verbose; must be placed before a subcommand";
                    },
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @(
                            @{
                                CompletionText = '--verbose';
                                ListItemText   = '--verbose';
                                ResultType     = 'ParameterName';
                                ToolTip        = "be verbose; must be placed before a subcommand";
                            },
                            @{
                                CompletionText = '--no-verbose';
                                ListItemText   = '--no-verbose';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] be verbose; must be placed before a subcommand";
                            }
                        )
                    },
                    @{
                        Line     = '--v';
                        Expected = @(
                            @{
                                CompletionText = '--verbose';
                                ListItemText   = '--verbose';
                                ResultType     = 'ParameterName';
                                ToolTip        = "be verbose; must be placed before a subcommand";
                            }
                        )
                    }
                ) {
                    "git remote $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Subcommands' {
                Context '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected = @(
                            @{Subcommand = 'add'; Description = 'Add a remote'; },
                            @{Subcommand = 'rename'; Description = 'Rename the remote name'; },
                            @{Subcommand = 'remove'; Description = 'Remove the remote name'; },
                            @{Subcommand = 'set-head'; Description = 'Sets or deletes the default branch for the named remote'; },
                            @{Subcommand = 'set-branches'; Description = 'Changes the list of branches tracked by the named remote'; },
                            @{Subcommand = 'get-url'; Description = 'Retrieves the URLs for a remote'; },
                            @{Subcommand = 'set-url'; Description = 'Changes URLs for the remote'; },
                            @{Subcommand = 'show'; Description = 'Gives some information'; },
                            @{Subcommand = 'prune'; Description = 'Deletes stale references'; },
                            @{Subcommand = 'update'; Description = 'Fetch updates for remotes or remote groups'; }
                        ) | ForEach-Object {
                            @{
                                CompletionText = $_.Subcommand;
                                ListItemText   = $_.Subcommand;
                                ResultType     = 'ParameterName';
                                ToolTip        = $_.Description;
                            }
                        }
                    },
                    @{
                        Line     = 'set-';
                        Expected = @(
                            @{Subcommand = 'set-head'; Description = 'Sets or deletes the default branch for the named remote'; },
                            @{Subcommand = 'set-branches'; Description = 'Changes the list of branches tracked by the named remote'; },
                            @{Subcommand = 'set-url'; Description = 'Changes URLs for the remote'; }
                        ) | ForEach-Object {
                            @{
                                CompletionText = $_.Subcommand;
                                ListItemText   = $_.Subcommand;
                                ResultType     = 'ParameterName';
                                ToolTip        = $_.Description;
                            }
                        }
                    }
                ) {
                    It '<_>' -ForEach @(
                        '',
                        '-v',
                        '--verbose',
                        '--no-verbose'
                    ) {
                        "git remote $_ $Line" | Complete-FromLine | Should -BeCompletion $expected
                    }
                }
            }
        }

        Describe 'add' {
            BeforeAll {
                Set-Variable Subcommand 'add'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-f';
                        ListItemText   = '-f';
                        ResultType     = 'ParameterName';
                        ToolTip        = "fetch the remote branches";
                    },
                    @{
                        CompletionText = '-m';
                        ListItemText   = '-m';
                        ResultType     = 'ParameterName';
                        ToolTip        = "master branch";
                    },
                    @{
                        CompletionText = '-t';
                        ListItemText   = '-t';
                        ResultType     = 'ParameterName';
                        ToolTip        = "branch(es) to track";
                    },
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--t';
                        Expected = @(
                            @{
                                CompletionText = '--tags';
                                ListItemText   = '--tags';
                                ResultType     = 'ParameterName';
                                ToolTip        = "import all tags and associated objects when fetching";
                            },
                            @{
                                CompletionText = '--track=';
                                ListItemText   = '--track=';
                                ResultType     = 'ParameterName';
                                ToolTip        = "branch(es) to track";
                            }
                        )
                    },
                    @{
                        Line     = '--no-t';
                        Expected = @(
                            @{
                                CompletionText = '--no-tags';
                                ListItemText   = '--no-tags';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] import all tags and associated objects when fetching";
                            },
                            @{
                                CompletionText = '--no-track';
                                ListItemText   = '--no-track';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] branch(es) to track";
                            }
                        )
                    },
                    @{
                        Line     = '--n';
                        Expected = @(
                            @{
                                CompletionText = '--no-fetch';
                                ListItemText   = '--no-fetch';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] fetch the remote branches";
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'None' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '.. ';
                        Expected = @()
                    },
                    @{
                        Line     = '--fetch ';
                        Expected = @()
                    },
                    @{
                        Line     = '';
                        Expected = @()
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'prune' {
            BeforeAll {
                Set-Variable Subcommand 'prune'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-n';
                        ListItemText   = '-n';
                        ResultType     = 'ParameterName';
                        ToolTip        = "dry run";
                    },
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @(
                            @{
                                CompletionText = '--dry-run';
                                ListItemText   = '--dry-run';
                                ResultType     = 'ParameterName';
                                ToolTip        = "dry run";
                            },
                            @{
                                CompletionText = '--no-dry-run';
                                ListItemText   = '--no-dry-run';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] dry run";
                            }
                        )
                    },
                    @{
                        Line     = '--no';
                        Expected = @(
                            @{
                                CompletionText = '--no-dry-run';
                                ListItemText   = '--no-dry-run';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] dry run";
                            }
                        )
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Remotes' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'o';
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'remove' {
            BeforeAll {
                Set-Variable Subcommand 'remove'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @()
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Remotes' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'o';
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'rename' {
            BeforeAll {
                Set-Variable Subcommand 'rename'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @(
                            @{
                                CompletionText = '--progress';
                                ListItemText   = '--progress';
                                ResultType     = 'ParameterName';
                                ToolTip        = "force progress reporting";
                            },
                            @{
                                CompletionText = '--no-progress';
                                ListItemText   = '--no-progress';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] force progress reporting";
                            }
                        )
                    },
                    @{
                        Line     = '--p';
                        Expected = @(
                            @{
                                CompletionText = '--progress';
                                ListItemText   = '--progress';
                                ResultType     = 'ParameterName';
                                ToolTip        = "force progress reporting";
                            }
                        )
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Remotes' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'o';
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'set-head' {
            BeforeAll {
                Set-Variable Subcommand 'set-head'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-a';
                        ListItemText   = '-a';
                        ResultType     = 'ParameterName';
                        ToolTip        = "set refs/remotes/<name>/HEAD according to remote";
                    },
                    @{
                        CompletionText = '-d';
                        ListItemText   = '-d';
                        ResultType     = 'ParameterName';
                        ToolTip        = "delete refs/remotes/<name>/HEAD";
                    },
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--d';
                        Expected = @(
                            @{
                                CompletionText = '--delete';
                                ListItemText   = '--delete';
                                ResultType     = 'ParameterName';
                                ToolTip        = "delete refs/remotes/<name>/HEAD";
                            }
                        )
                    },
                    @{
                        Line     = '--no-d';
                        Expected = @(
                            @{
                                CompletionText = '--no-delete';
                                ListItemText   = '--no-delete';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] delete refs/remotes/<name>/HEAD";
                            }
                        )
                    },
                    @{
                        Line     = '--no';
                        Expected = @(
                            @{
                                CompletionText = '--no-auto';
                                ListItemText   = '--no-auto';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] set refs/remotes/<name>/HEAD according to remote";
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'set-branches' {
            BeforeAll {
                Set-Variable Subcommand 'set-branches'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @(
                            @{
                                CompletionText = '--add';
                                ListItemText   = '--add';
                                ResultType     = 'ParameterName';
                                ToolTip        = "add branch";
                            },
                            @{
                                CompletionText = '--no-add';
                                ListItemText   = '--no-add';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] add branch";
                            }
                        )
                    },
                    @{
                        Line     = '--a';
                        Expected = @(
                            @{
                                CompletionText = '--add';
                                ListItemText   = '--add';
                                ResultType     = 'ParameterName';
                                ToolTip        = "add branch";
                            }
                        )
                    },
                    @{
                        Line     = '--no';
                        Expected = @(
                            @{
                                CompletionText = '--no-add';
                                ListItemText   = '--no-add';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] add branch";
                            }
                        )
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'get-url' {
            BeforeAll {
                Set-Variable Subcommand 'get-url'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--a';
                        Expected = @(
                            @{
                                CompletionText = '--all';
                                ListItemText   = '--all';
                                ResultType     = 'ParameterName';
                                ToolTip        = "return all URLs";
                            }
                        )
                    },
                    @{
                        Line     = '--no-a';
                        Expected = @(
                            @{
                                CompletionText = '--no-all';
                                ListItemText   = '--no-all';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] return all URLs";
                            }
                        )
                    },
                    @{
                        Line     = '--no';
                        Expected = @(
                            @{
                                CompletionText = '--no-push';
                                ListItemText   = '--no-push';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] query push URLs rather than fetch URLs";
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Remotes' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'o';
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'set-url' {
            BeforeAll {
                Set-Variable Subcommand 'set-url'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--a';
                        Expected = @(
                            @{
                                CompletionText = '--add';
                                ListItemText   = '--add';
                                ResultType     = 'ParameterName';
                                ToolTip        = "add URL";
                            }
                        )
                    },
                    @{
                        Line     = '--no-a';
                        Expected = @(
                            @{
                                CompletionText = '--no-add';
                                ListItemText   = '--no-add';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] add URL";
                            }
                        )
                    },
                    @{
                        Line     = '--no';
                        Expected = @(
                            @{
                                CompletionText = '--no-push';
                                ListItemText   = '--no-push';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] manipulate push URLs";
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Remotes' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'o';
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'show' {
            BeforeAll {
                Set-Variable Subcommand 'show'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-n';
                        ListItemText   = '-n';
                        ResultType     = 'ParameterName';
                        ToolTip        = "do not query remotes";
                    },
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @()
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Remotes' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'o';
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'update' {
            BeforeAll {
                Set-Variable Subcommand 'update'
            }

            It 'ShortOptions' {
                $expected = @(
                    @{
                        CompletionText = '-p';
                        ListItemText   = '-p';
                        ResultType     = 'ParameterName';
                        ToolTip        = "prune remotes after fetching";
                    },
                    @{
                        CompletionText = '-h';
                        ListItemText   = '-h';
                        ResultType     = 'ParameterName';
                        ToolTip        = "show help";
                    }
                )
                "git remote $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @(
                            @{
                                CompletionText = '--prune';
                                ListItemText   = '--prune';
                                ResultType     = 'ParameterName';
                                ToolTip        = "prune remotes after fetching";
                            },
                            @{
                                CompletionText = '--no-prune';
                                ListItemText   = '--no-prune';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] prune remotes after fetching";
                            }
                        )
                    },
                    @{
                        Line     = '--p';
                        Expected = @(
                            @{
                                CompletionText = '--prune';
                                ListItemText   = '--prune';
                                ResultType     = 'ParameterName';
                                ToolTip        = "prune remotes after fetching";
                            }
                        )
                    },
                    @{
                        Line     = '--no';
                        Expected = @(
                            @{
                                CompletionText = '--no-prune';
                                ListItemText   = '--no-prune';
                                ResultType     = 'ParameterName';
                                ToolTip        = "[NO] prune remotes after fetching";
                            }
                        )
                    }
                ) {
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'RemoteOrGroup' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = 'origin d';
                        Expected = @(
                            'default'
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
                        Line     = 'or or';
                        Expected = @(
                            'ordinary',
                            'origin',
                            'ors'
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
                        Line     = 'or';
                        Expected = @(
                            'ordinary',
                            'origin',
                            'ors'
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
                            'origin',
                            'default',
                            'ors'
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
                    "git remote $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
}
