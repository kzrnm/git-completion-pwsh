. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

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
            Expected = "--version" | ConvertTo-Completion -ResultType ParameterName -ToolTip "Prints the Git suite version"
        },
        @{
            Line     = "--attr-sourc";
            Expected = @{
                CompletionText = "--attr-source";
                ListItemText   = "--attr-source <tree-ish>";
                ToolTip        = "Read gitattributes from <tree-ish> instead of the worktree";
            } | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Line     = "-";
            Expected = @{
                ListItemText = "-v";
                ToolTip      = "Prints the Git suite version";
            },
            @{
                ListItemText = "-h";
                ToolTip      = "Prints the helps. If --all is given then all available commands are printed";
            },
            @{
                CompletionText = "-C";
                ListItemText   = "-C <path>";
                ToolTip        = "Run as if git was started in <path> instead of the current working directory";
            },
            @{
                CompletionText = "-c";
                ListItemText   = "-c <name>=<value>";
                ToolTip        = "Pass a configuration parameter to the command";
            },
            @{
                ListItemText = "-p";
                ToolTip      = 'Pipe all output into less (or if set, $PAGER) if standard output is a terminal';
            },
            @{
                ListItemText = "-P";
                ToolTip      = "Do not pipe Git output into a pager";
            } | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Line     = "sw";
            Expected = @{
                ListItemText = "sw";
                ToolTip      = "[alias] switch";
            },
            @{
                ListItemText = "swf";
                ToolTip      = "[alias] sw -f";
            },
            @{
                ListItemText = "switch";
                ToolTip      = "Switch branches";
            } | ConvertTo-Completion -ResultType Text
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
                                ListItemText = "whatchanged";
                                ToolTip      = "Show logs with differences each commit introduces";
                            },
                            @{
                                ListItemText = "worktree";
                                ToolTip      = "Manage multiple working trees";
                            },
                            @{
                                ListItemText = "write-tree";
                                ToolTip      = "Create a tree object from the current index";
                            } | ConvertTo-Completion -ResultType Text
                        )
                        $false = @(
                            @{
                                ListItemText = "whatchanged";
                                ToolTip      = "Show logs with differences each commit introduces";
                            },
                            @{
                                ListItemText = "worktree";
                                ToolTip      = "Manage multiple working trees";
                            } | ConvertTo-Completion -ResultType Text
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
                Expected = "whatchanged" | ConvertTo-Completion -ResultType Text -ToolTip "Show logs with differences each commit introduces"
            },
            @{
                Add      = 'why';
                Exclude  = @();
                Command  = 'wh';
                Expected = @{
                    ListItemText   = "whatchanged";
                    ToolTip        = "Show logs with differences each commit introduces";
                },
                @{
                    ListItemText   = "why";
                    ToolTip        = "why";
                } | ConvertTo-Completion -ResultType Text
            },
            @{
                Add      = @('why', 'who');
                Exclude  = @();
                Command  = 'wh';
                Expected = @(@{
                        ListItemText   = "whatchanged";
                        ToolTip        = "Show logs with differences each commit introduces";
                    }, "who", "why" | ConvertTo-Completion -ResultType Text)
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
                Expected = "why" | ConvertTo-Completion -ResultType Text
            },
            @{
                Add      = @('why', 'who');
                Exclude  = @('whatchanged', 'who');
                Command  = 'wh';
                Expected = "why" | ConvertTo-Completion -ResultType Text
            },
            @{
                Add      = @('ls-files');
                Exclude  = @();
                Command  = 'ls';
                Expected = "ls-files" | ConvertTo-Completion -ResultType Text -ToolTip "Show information about files in the index and the working tree"
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
