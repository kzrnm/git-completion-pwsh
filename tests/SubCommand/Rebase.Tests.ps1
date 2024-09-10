using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        $ErrorActionPreference = 'SilentlyContinue'
        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath

        (1..100) > Number.txt
        git add Number.txt
        git commit -m asc
        (99..20) > Number.txt
        git add Number.txt
        git commit -m desc
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be quiet. implies --no-stat'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be quiet. implies --no-stat'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- --';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist -Ref {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-C';
            ToolTip      = "passed to 'git apply'";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "cherry-pick all commits, even if unchanged";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "let the user edit the list of commits to rebase";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "use merging strategies to rebase";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "do not show diffstat of what changed upstream";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be quiet. implies --no-stat";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "try to rebase merges instead of skipping them";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "use the given merge strategy";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG-sign commits";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "display a diffstat of what changed upstream";
        },
        @{
            ListItemText = '-x';
            ToolTip      = "add exec lines after each commit of the editable list";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "pass the argument through to the merge strategy";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--a';
                Expected = @{
                    ListItemText = '--apply';
                    ToolTip      = "use apply strategies to rebase";
                },
                @{
                    ListItemText = '--autosquash';
                    ToolTip      = "move commits that begin with squash!/fixup! under -i";
                },
                @{
                    ListItemText = '--autostash';
                    ToolTip      = "automatically stash/stash pop before and after";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--c';
                Expected = @{
                    ListItemText = '--committer-date-is-author-date';
                    ToolTip      = "make committer date match author date";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--f';
                Expected = @{
                    ListItemText = '--force-rebase';
                    ToolTip      = "cherry-pick all commits, even if unchanged";
                },
                @{
                    ListItemText = '--fork-point';
                    ToolTip      = "use 'merge-base --fork-point' to refine upstream";
                },
                @{
                    ListItemText = '--ff';
                    ToolTip      = "opposite of --no-ff";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-v';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "allow pre-rebase hook to run";
                },
                @{
                    ListItemText = '--no-verbose';
                    ToolTip      = "[NO] display a diffstat of what changed upstream";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-ff';
                    ToolTip      = "cherry-pick all commits, even if unchanged";
                },
                @{
                    ListItemText = '--no-force-rebase';
                    ToolTip      = "[NO] cherry-pick all commits, even if unchanged";
                },
                @{
                    ListItemText = '--no-fork-point';
                    ToolTip      = "[NO] use 'merge-base --fork-point' to refine upstream";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "allow pre-rebase hook to run";
                },
                @{
                    ListItemText = '--no-stat';
                    ToolTip      = "do not show diffstat of what changed upstream";
                },
                @{
                    ListItemText = '--no-ff';
                    ToolTip      = "cherry-pick all commits, even if unchanged";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text';
                } | ConvertTo-Completion -ResultType ParameterName
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
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-s o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy=o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy=$_" }
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
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option r';
                    Expected = @(
                        'renormalize',
                        'rename-threshold='
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option=r';
                    Expected = @(
                        'renormalize',
                        'rename-threshold='
                    ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy-option=$_" }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Revlist:<_>' -ForEach @('--onto') {
            BeforeDiscovery {
                $option = $_
                Set-Variable 'Data' @(
                    @{
                        Line     = "$option ";
                        Expected =
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = "$option o";
                        Expected = 
                        'ordinary/develop',
                        'origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = "$option ^";
                        Expected =
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = "$option ^o";
                        Expected = 
                        '^ordinary/develop',
                        '^origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                    }
                )

                if ($option.StartsWith('--')) {
                    $Data += @(
                        @{
                            Line     = "$option=";
                            Expected =
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        },
                        @{
                            Line     = "$option=o";
                            Expected = 
                            'ordinary/develop',
                            'origin/develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        },
                        @{
                            Line     = "$option=^";
                            Expected =
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        },
                        @{
                            Line     = "$option=^o";
                            Expected = 
                            '^ordinary/develop',
                            '^origin/develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        }
                    )
                }
            }

            It '<Line>' -ForEach $Data {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--whitespace ';
                Expected = 
                'nowarn', 'warn', 'error', 'error-all', 'fix' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--whitespace e';
                Expected = 
                'error', 'error-all' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--whitespace=';
                Expected =
                'nowarn', 'warn', 'error', 'error-all', 'fix' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--whitespace=$_" }
            },
            @{
                Line     = '--whitespace=e';
                Expected =
                'error', 'error-all' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--whitespace=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist -Ref


    Describe 'InProgress:<_>' -ForEach @('apply', 'merge') {
        BeforeAll {
            New-Item ".git/rebase-$_" -ItemType Directory
        }
        AfterAll {
            Remove-Item ".git/rebase-$_"
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = @{
                        ListItemText = '--continue';
                        ToolTip      = "continue";
                    },
                    @{
                        ListItemText = '--skip';
                        ToolTip      = "skip current patch and continue";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort and check out the original branch";
                    },
                    @{
                        ListItemText = '--quit';
                        ToolTip      = "abort but keep HEAD where it is";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch file being applied or merged";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '-';
                    Expected = @{
                        ListItemText = '--continue';
                        ToolTip      = "continue";
                    },
                    @{
                        ListItemText = '--skip';
                        ToolTip      = "skip current patch and continue";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort and check out the original branch";
                    },
                    @{
                        ListItemText = '--quit';
                        ToolTip      = "abort but keep HEAD where it is";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch file being applied or merged";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--continue';
                        ToolTip      = "continue";
                    },
                    @{
                        ListItemText = '--skip';
                        ToolTip      = "skip current patch and continue";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort and check out the original branch";
                    },
                    @{
                        ListItemText = '--quit';
                        ToolTip      = "abort but keep HEAD where it is";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch file being applied or merged";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--continue'
                        ToolTip      = "continue";
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'InProgressInteractive' {
        BeforeAll {
            @'
#!/bin/sh
cat "$1" | sed -e s/pick/e/g > ".rebase"
mv ".rebase" "$1"
'@ | Out-File "$TestDrive/rebase-tool.sh" -Encoding ascii
            if (Get-Command chmod) {
                chmod +x "$TestDrive/rebase-tool.sh"
            }
            git -c "sequence.editor=$TestDrive/rebase-tool.sh".Replace('\','/') rebase -i zeta
        }
        AfterAll {
            git rebase --abort 2>$null
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = @{
                        ListItemText = '--continue';
                        ToolTip      = "continue";
                    },
                    @{
                        ListItemText = '--skip';
                        ToolTip      = "skip current patch and continue";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort and check out the original branch";
                    },
                    @{
                        ListItemText = '--quit';
                        ToolTip      = "abort but keep HEAD where it is";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch file being applied or merged";
                    },
                    @{
                        ListItemText = '--edit-todo';
                        ToolTip      = "edit the todo list during an interactive rebase";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '-';
                    Expected = @{
                        ListItemText = '--continue';
                        ToolTip      = "continue";
                    },
                    @{
                        ListItemText = '--skip';
                        ToolTip      = "skip current patch and continue";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort and check out the original branch";
                    },
                    @{
                        ListItemText = '--quit';
                        ToolTip      = "abort but keep HEAD where it is";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch file being applied or merged";
                    },
                    @{
                        ListItemText = '--edit-todo';
                        ToolTip      = "edit the todo list during an interactive rebase";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--continue';
                        ToolTip      = "continue";
                    },
                    @{
                        ListItemText = '--skip';
                        ToolTip      = "skip current patch and continue";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort and check out the original branch";
                    },
                    @{
                        ListItemText = '--quit';
                        ToolTip      = "abort but keep HEAD where it is";
                    },
                    @{
                        ListItemText = '--show-current-patch';
                        ToolTip      = "show the patch file being applied or merged";
                    },
                    @{
                        ListItemText = '--edit-todo';
                        ToolTip      = "edit the todo list during an interactive rebase";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--continue'
                        ToolTip      = "continue";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--e';
                    Expected = @{
                        ListItemText = '--edit-todo';
                        ToolTip      = "edit the todo list during an interactive rebase";
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}