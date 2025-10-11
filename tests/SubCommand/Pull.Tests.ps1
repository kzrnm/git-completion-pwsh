# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = '-- -';
                Expected = @()
            },
            @{
                Line     = '-- --';
                Expected = @()
            },
            @{
                Line     = 'origin -- -';
                Expected = @()
            },
            @{
                Line     = 'origin -- --';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-4';
            ToolTip      = "use IPv4 addresses only";
        },
        @{
            ListItemText = '-6';
            ToolTip      = "use IPv6 addresses only";
        },
        @{
            ListItemText = '-a';
            ToolTip      = "append to .git/FETCH_HEAD instead of overwriting";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force overwrite of local branch";
        },
        @{
            ListItemText = '-j';
            ToolTip      = "number of submodules pulled in parallel";
        },
        @{
            ListItemText = '-k';
            ToolTip      = "keep downloaded pack";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "do not show a diffstat at the end of the merge";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "option to transmit";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "prune remote-tracking branches no longer on remote";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "incorporate changes by rebasing rather than merging";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "merge strategy to use";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG sign commit";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "fetch all tags and associated objects";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be more verbose";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "option for selected merge strategy";
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
                Line     = '--ip';
                Expected = @{
                    ListItemText = '--ipv4';
                    ToolTip      = "use IPv4 addresses only";
                },
                @{
                    ListItemText = '--ipv6';
                    ToolTip      = "use IPv6 addresses only";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-ip';
                Expected = @{
                    ListItemText = '--no-ipv4';
                    ToolTip      = "[NO] use IPv4 addresses only";
                },
                @{
                    ListItemText = '--no-ipv6';
                    ToolTip      = "[NO] use IPv6 addresses only";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verbose';
                    ToolTip      = "[NO] be more verbose";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
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
                    Expected = 
                    'octopus',
                    'ours',
                    'recursive',
                    'resolve',
                    'subtree' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-s o';
                    Expected = 
                    'octopus',
                    'ours' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy ';
                    Expected = 
                    'octopus',
                    'ours',
                    'recursive',
                    'resolve',
                    'subtree' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy o';
                    Expected = 
                    'octopus',
                    'ours' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy=o';
                    Expected = 
                    'octopus',
                    'ours' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy=$_" }
                },
                @{
                    Line     = '--strategy-option ';
                    Expected = @{
                        ListItemText = 'diff-algorithm=';
                        Tooltip      = 'Use a different diff algorithm while merging';
                    },
                    @{
                        ListItemText = 'find-renames';
                        Tooltip      = 'Turn on rename detection';
                    },
                    @{
                        ListItemText = 'find-renames=';
                        Tooltip      = 'Turn on rename detection, optionally setting the similarity threshold';
                    },
                    @{
                        ListItemText = 'histogram';
                        Tooltip      = 'Deprecated synonym for diff-algorithm=histogram';
                    },
                    @{
                        ListItemText = 'ignore-all-space';
                        Tooltip      = 'Ignore whitespace when comparing lines';
                    },
                    @{
                        ListItemText = 'ignore-space-at-eol';
                        Tooltip      = 'Ignore changes in whitespace at EOL';
                    },
                    @{
                        ListItemText = 'ignore-space-change';
                        Tooltip      = 'Ignore changes in amount of whitespace';
                    },
                    @{
                        ListItemText = 'no-renames';
                        Tooltip      = 'Turn off rename detection';
                    },
                    @{
                        ListItemText = 'no-renormalize';
                        Tooltip      = '[NO] runs a virtual check-out and check-in of all three stages';
                    },
                    @{
                        ListItemText = 'ours';
                        Tooltip      = 'favoring our version';
                    },
                    @{
                        ListItemText = 'patience';
                        Tooltip      = 'Deprecated synonym for diff-algorithm=patience';
                    },
                    @{
                        ListItemText = 'rename-threshold=';
                        Tooltip      = 'Deprecated synonym for find-renames=';
                    },
                    @{
                        ListItemText = 'renormalize';
                        Tooltip      = 'runs a virtual check-out and check-in of all three stages';
                    },
                    @{
                        ListItemText = 'subtree';
                        Tooltip      = 'A more advanced form of subtree strategy';
                    },
                    @{
                        ListItemText = 'subtree=';
                        Tooltip      = 'A more advanced form of subtree strategy';
                    },
                    @{
                        ListItemText = 'theirs';
                        Tooltip      = 'opposite of ours';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option r';
                    Expected = @{
                        ListItemText = 'rename-threshold=';
                        Tooltip      = 'Deprecated synonym for find-renames=';
                    },
                    @{
                        ListItemText = 'renormalize';
                        Tooltip      = 'runs a virtual check-out and check-in of all three stages';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option=r';
                    Expected = @{
                        ListItemText = 'rename-threshold=';
                        Tooltip      = 'Deprecated synonym for find-renames=';
                    },
                    @{
                        ListItemText = 'renormalize';
                        Tooltip      = 'runs a virtual check-out and check-in of all three stages';
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy-option=$_" }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = '--recurse-submodules ';
                Expected = @{
                    ListItemText = 'no';
                    Tooltip      = 'no submodules are fetched';
                },
                @{
                    ListItemText = 'on-demand';
                    Tooltip      = '(default) only changed submodules are fetched';
                },
                @{
                    ListItemText = 'yes';
                    Tooltip      = 'all submodules are fetched';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--recurse-submodules y';
                Expected = @{
                    ListItemText = 'yes';
                    Tooltip      = 'all submodules are fetched';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = @{
                    ListItemText = 'no';
                    Tooltip      = 'no submodules are fetched';
                },
                @{
                    ListItemText = 'on-demand';
                    Tooltip      = '(default) only changed submodules are fetched';
                },
                @{
                    ListItemText = 'yes';
                    Tooltip      = 'all submodules are fetched';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--recurse-submodules=$_" }
            },
            @{
                Line     = '--recurse-submodules=y';
                Expected = @{
                    ListItemText = 'yes';
                    Tooltip      = 'all submodules are fetched';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--recurse-submodules=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'RemoteOrRefspec' {
        Describe '<Line>' -ForEach @(
            @{
                Line     = 'origin ';
                Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin d';
                Expected = 
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin +';
                Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
            },
            @{
                Line     = 'origin +d';
                Expected = 
                'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
            },
            @{
                Line     = 'origin left:';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/HEAD',
                'grm/develop',
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop',
                'initial',
                'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
            },
            @{
                Line     = 'origin left:m';
                Expected = 
                'main' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
            },
            @{
                Line     = 'or';
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            Describe 'DoubleDash' {
                It '<DoubleDash>' -ForEach @('--', '--quiet --' | ForEach-Object { @{DoubleDash = $_; } }) {
                    "git $Command $DoubleDash $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            It '_' {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}
