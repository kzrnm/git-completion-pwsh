# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'GirGlobal' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
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
            Line     = "-NO";
            Expected = @()
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
            Line     = "--notmatch";
            Expected = @()
        }
    ) {
        "git $line" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Complete subcommands' {
        Describe 'alias' {
            BeforeAll {
                git config set alias.sw "switch"
                git config set alias.swf "sw -f"
                git config set alias.swc "sw`n--create"
            }
            AfterAll {
                git config unset alias.sw
                git config unset alias.swf
                git config unset alias.swc
            }
            It '<Line>' -ForEach @(
                @{
                    Line     = "sw";
                    Expected = @{
                        ListItemText = "sw";
                        ToolTip      = "[alias] switch";
                    },
                    @{
                        ListItemText = "swc";
                        ToolTip      = "[alias] sw --create";
                    },
                    @{
                        ListItemText = "swf";
                        ToolTip      = "[alias] sw -f";
                    },
                    @{
                        ListItemText = "switch";
                        ToolTip      = "Switch branches";
                    } | ConvertTo-Completion -ResultType Text
                }
            ) {
                "git $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }

        Describe 'ShowAllCommand' {
            Describe '<Line>' -ForEach @(
                @{
                    Line     = 'w';
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
                It '<_>' -ForEach @($true, $false) {
                    $GitCompletionSettings.ShowAllCommand = $_
                    "git -c alias.sw='switch' -c alias.swf='sw -f' $Line" | Complete-FromLine | Should -BeCompletion $Expected[$_]
                }
            }
            AfterEach {
                $GitCompletionSettings.ShowAllCommand = $false
            }
        }

        Describe 'AdditionalCommands,ExcludeCommands' {
            Describe '<Command>,Add:(<Add>),Exclude:(<Exclude>)' -ForEach @(
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
                        ListItemText = "whatchanged";
                        ToolTip      = "Show logs with differences each commit introduces";
                    },
                    @{
                        ListItemText = "why";
                        ToolTip      = "why";
                    } | ConvertTo-Completion -ResultType Text
                },
                @{
                    Add      = @('why', 'who');
                    Exclude  = @();
                    Command  = 'wh';
                    Expected = @(@{
                            ListItemText = "whatchanged";
                            ToolTip      = "Show logs with differences each commit introduces";
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
                It '<Command>' {
                    "git $Command" | Complete-FromLine | Should -BeCompletion $Expected
                }

                It 'First is Add' {
                    "git " | Complete-FromLine | Select-Object -First 1 | Should -BeCompletion (
                        @{
                            ListItemText = "add";
                            ToolTip      = "Add file contents to the index";
                        } | ConvertTo-Completion -ResultType Text
                    )
                }

                BeforeEach {
                    $GitCompletionSettings.AdditionalCommands = $Add
                    $GitCompletionSettings.ExcludeCommands = $Exclude
                }

                AfterEach {
                    $GitCompletionSettings.AdditionalCommands = @()
                    $GitCompletionSettings.ExcludeCommands = @()
                }
            }
        }
    }
}
