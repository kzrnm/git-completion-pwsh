BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe 'GirGlobal' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
        git config alias.sw "switch"
        git config alias.swf "sw -f"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }
    It '<line>' -ForEach @(
        @{
            Line     = "--ver";
            Expected = @(
                @{
                    CompletionText = "--version";
                    ListItemText   = "--version";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Prints the Git suite version";
                }
            )
        },
        @{
            Line     = "--attr-sourc";
            Expected = @(
                @{
                    CompletionText = "--attr-source";
                    ListItemText   = "--attr-source <tree-ish>";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Read gitattributes from <tree-ish> instead of the worktree";
                }
            )
        },
        @{
            Line     = "-";
            Expected = @(
                @{
                    CompletionText = "-v";
                    ListItemText   = "-v";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Prints the Git suite version";
                },
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Prints the helps. If --all is given then all available commands are printed";
                },
                @{
                    CompletionText = "-C";
                    ListItemText   = "-C <path>";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Run as if git was started in <path> instead of the current working directory";
                },
                @{
                    CompletionText = "-c";
                    ListItemText   = "-c <name>=<value>";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Pass a configuration parameter to the command";
                },
                @{
                    CompletionText = "-p";
                    ListItemText   = "-p";
                    ResultType     = 'ParameterName';
                    ToolTip        = 'Pipe all output into less (or if set, $PAGER) if standard output is a terminal';
                },
                @{
                    CompletionText = "-P";
                    ListItemText   = "-P";
                    ResultType     = 'ParameterName';
                    ToolTip        = "Do not pipe Git output into a pager";
                }
            )
        },
        @{
            Line     = "sw";
            Expected = @(
                @{
                    CompletionText = "sw";
                    ListItemText   = "sw";
                    ResultType     = "Text";
                    ToolTip        = "[alias] switch";
                },
                @{
                    CompletionText = "swf";
                    ListItemText   = "swf";
                    ResultType     = "Text";
                    ToolTip        = "[alias] sw -f";
                },
                @{
                    CompletionText = "switch";
                    ListItemText   = "switch";
                    ResultType     = "Text";
                    ToolTip        = "Switch branches";
                }
            )
        },
        @{
            Line     = "--notmatch";
            Expected = @()
        }
    ) {
        "git $line" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Complete subcommands' {
        Describe 'ShowAllCommand' {
            Describe '<Line>' -ForEach @(
                @{
                    Line     = 'git w';
                    Expected = @{
                        $true  = @(
                            @{
                                CompletionText = "whatchanged";
                                ListItemText   = "whatchanged";
                                ResultType     = 'Text';
                                ToolTip        = "Show logs with differences each commit introduces";
                            },
                            @{
                                CompletionText = "worktree";
                                ListItemText   = "worktree";
                                ResultType     = 'Text';
                                ToolTip        = "Manage multiple working trees";
                            },
                            @{
                                CompletionText = "write-tree";
                                ListItemText   = "write-tree";
                                ResultType     = 'Text';
                                ToolTip        = "Create a tree object from the current index";
                            }
                        )
                        $false = @(
                            @{
                                CompletionText = "whatchanged";
                                ListItemText   = "whatchanged";
                                ResultType     = 'Text';
                                ToolTip        = "Show logs with differences each commit introduces";
                            },
                            @{
                                CompletionText = "worktree";
                                ListItemText   = "worktree";
                                ResultType     = 'Text';
                                ToolTip        = "Manage multiple working trees";
                            }
                        )
                    }
                }
            ) {
                It '<_>'  -ForEach @($true, $false) {
                    $GitCompletionSettings.ShowAllCommand = $_
                    "$Line" | Complete-FromLine | Should -BeCompletion $Expected[$_]
                }
            }
        }

        AfterEach {
            $GitCompletionSettings.ShowAllCommand = $false
        }
    }

    Describe 'AdditionalCommands,ExcludeCommands' {
        It '<Command>,Add:(<Add>),Exclude:(<Exclude>)' -ForEach @(
            @{
                Add      = @();
                Exclude  = @();
                Command  = 'wh';
                Expected = @(
                    @{
                        CompletionText = "whatchanged";
                        ListItemText   = "whatchanged";
                        ResultType     = 'Text';
                        ToolTip        = "Show logs with differences each commit introduces";
                    }
                )
            },
            @{
                Add      = 'why';
                Exclude  = @();
                Command  = 'wh';
                Expected = @(
                    @{
                        CompletionText = "whatchanged";
                        ListItemText   = "whatchanged";
                        ResultType     = 'Text';
                        ToolTip        = "Show logs with differences each commit introduces";
                    },
                    @{
                        CompletionText = "why";
                        ListItemText   = "why";
                        ResultType     = 'Text';
                        ToolTip        = "why";
                    }
                )
            },
            @{
                Add      = @('why', 'who');
                Exclude  = @();
                Command  = 'wh';
                Expected = @(
                    @{
                        CompletionText = "whatchanged";
                        ListItemText   = "whatchanged";
                        ResultType     = 'Text';
                        ToolTip        = "Show logs with differences each commit introduces";
                    },
                    @{
                        CompletionText = "who";
                        ListItemText   = "who";
                        ResultType     = 'Text';
                        ToolTip        = "who";
                    },
                    @{
                        CompletionText = "why";
                        ListItemText   = "why";
                        ResultType     = 'Text';
                        ToolTip        = "why";
                    }
                )
            },
            @{
                Add      = @();
                Exclude  = 'whatchanged';
                Command  = 'wh';
                Expected = @()
            },
            @{
                Add      = 'why';
                Exclude  = @('whatchanged', 'worktree');
                Command  = 'w';
                Expected = @(
                    @{
                        CompletionText = "why";
                        ListItemText   = "why";
                        ResultType     = 'Text';
                        ToolTip        = "why";
                    }
                )
            },
            @{
                Add      = @('why', 'who');
                Exclude  = @('whatchanged', 'who');
                Command  = 'wh';
                Expected = @(
                    @{
                        CompletionText = "why";
                        ListItemText   = "why";
                        ResultType     = 'Text';
                        ToolTip        = "why";
                    }
                )
            },
            @{
                Add      = @('ls-files');
                Exclude  = @();
                Command  = 'ls';
                Expected = @(
                    @{
                        CompletionText = "ls-files";
                        ListItemText   = "ls-files";
                        ResultType     = 'Text';
                        ToolTip        = "Show information about files in the index and the working tree";
                    }
                )
            }
        ) {
            $GitCompletionSettings.AdditionalCommands = $Add
            $GitCompletionSettings.ExcludeCommands = $Exclude

            "git $Command" | Complete-FromLine | Should -BeCompletion $Expected
        }
    }

    AfterEach {
        $GitCompletionSettings.ShowAllCommand = $false
    }
}
