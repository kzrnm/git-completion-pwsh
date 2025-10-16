# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

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
                    Left     = '--no-prefix';
                    Right    = ' --';
                    Expected = '--no-prefix' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--no-prefix'
                },
                @{
                    Left     = '--no-prefix';
                    Right    = ' -- --all';
                    Expected = '--no-prefix' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--no-prefix'
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
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            },
            @{
                Line     = '-- ';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-a';
            ToolTip      = "treat all files as text.";
        },
        @{
            ListItemText = '-B';
            ToolTip      = "detect complete rewrites.";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "detect copies.";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "limit rename attempts up to <n> paths.";
        },
        @{
            ListItemText = '-M';
            ToolTip      = "detect renames.";
        },
        @{
            ListItemText = '-O';
            ToolTip      = "reorder diffs according to the <file>.";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "output patch format.";
        },
        @{
            ListItemText = '-R';
            ToolTip      = "swap input file pairs.";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "find filepair whose only one side contains the string.";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "synonym for -p.";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "output diff-raw with lines terminated with NUL.";
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
                Line     = '--b';
                Expected = '--base', '--binary', '--break-rewrites' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-p';
                Expected = '--no-patch', '--no-prefix' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--color-moved-ws i';
                Expected = @{
                    ListItemText = 'ignore-all-space';
                    Tooltip      = 'Ignore whitespace when comparing lines';                },
                @{
                    ListItemText = 'ignore-space-at-eol';
                    Tooltip      = 'Ignore changes in whitespace at EOL';                },
                @{
                    ListItemText = 'ignore-space-change';
                    Tooltip      = 'Ignore changes in amount of whitespace';                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--color-moved-ws ';
                Expected = @{
                    ListItemText = 'allow-indentation-change';
                    Tooltip      = 'Initially ignore any whitespace in the move detection, then group the moved code blocks only into a block if the change in whitespace is the same per line';                },
                @{
                    ListItemText = 'ignore-all-space';
                    Tooltip      = 'Ignore whitespace when comparing lines';                },
                @{
                    ListItemText = 'ignore-space-at-eol';
                    Tooltip      = 'Ignore changes in whitespace at EOL';                },
                @{
                    ListItemText = 'ignore-space-change';
                    Tooltip      = 'Ignore changes in amount of whitespace';                },
                @{
                    ListItemText = 'no';
                    Tooltip      = 'Do not ignore whitespace when performing move detection';                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--color-moved-ws=i';
                Expected = @{
                    ListItemText = 'ignore-all-space';
                    Tooltip      = 'Ignore whitespace when comparing lines';                },
                @{
                    ListItemText = 'ignore-space-at-eol';
                    Tooltip      = 'Ignore changes in whitespace at EOL';                },
                @{
                    ListItemText = 'ignore-space-change';
                    Tooltip      = 'Ignore changes in amount of whitespace';                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved-ws=$_" }
            },
            @{
                Line     = '--color-moved-ws=';
                Expected = @{
                    ListItemText = 'allow-indentation-change';
                    Tooltip      = 'Initially ignore any whitespace in the move detection, then group the moved code blocks only into a block if the change in whitespace is the same per line';                },
                @{
                    ListItemText = 'ignore-all-space';
                    Tooltip      = 'Ignore whitespace when comparing lines';                },
                @{
                    ListItemText = 'ignore-space-at-eol';
                    Tooltip      = 'Ignore changes in whitespace at EOL';                },
                @{
                    ListItemText = 'ignore-space-change';
                    Tooltip      = 'Ignore changes in amount of whitespace';                },
                @{
                    ListItemText = 'no';
                    Tooltip      = 'Do not ignore whitespace when performing move detection';                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved-ws=$_" }
            },
            @{
                Line     = '--color-moved=d';
                Expected = @{
                    ListItemText = 'default';
                    Tooltip      = 'A synonym for zebra';                },
                @{
                    ListItemText = 'dimmed-zebra';
                    Tooltip      = 'Similar to zebra, but additional dimming of uninteresting parts of moved code is performed';                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved=$_" }
            },
            @{
                Line     = '--color-moved=';
                Expected = @{
                    ListItemText = 'blocks';
                    Tooltip      = 'Blocks of moved text of at least 20 alphanumeric characters are detected greedily';                },
                @{
                    ListItemText = 'default';
                    Tooltip      = 'A synonym for zebra';                },
                @{
                    ListItemText = 'dimmed-zebra';
                    Tooltip      = 'Similar to zebra, but additional dimming of uninteresting parts of moved code is performed';                },
                @{
                    ListItemText = 'no';
                    Tooltip      = 'Moved lines are not highlighted';                },
                @{
                    ListItemText = 'plain';
                    Tooltip      = 'Any line that is added in one location and was removed in another location will be colored with color.diff.newMoved';                },
                @{
                    ListItemText = 'zebra';
                    Tooltip      = 'Blocks of moved text are detected as in blocks mode';                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved=$_" }
            },
            @{
                Line     = '--ws-error-highlight d';
                Expected = @{
                    ListItemText = 'default';
                    Tooltip      = 'A synonym for new';                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--ws-error-highlight ';
                Expected = @{
                    ListItemText = 'all';
                    Tooltip      = 'A synonym for old,new,context';                },
                @{
                    ListItemText = 'context';
                    Tooltip      = 'Highlight whitespace errors in the context';                },
                @{
                    ListItemText = 'default';
                    Tooltip      = 'A synonym for new';                },
                @{
                    ListItemText = 'new';
                    Tooltip      = 'Highlight whitespace errors in the new lines of the diff';                },
                @{
                    ListItemText = 'old';
                    Tooltip      = 'Highlight whitespace errors in the old lines of the diff';                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--ws-error-highlight=d';
                Expected = @{
                    ListItemText = 'default';
                    Tooltip      = 'A synonym for new';                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
            },
            @{
                Line     = '--ws-error-highlight=';
                Expected = @{
                    ListItemText = 'all';
                    Tooltip      = 'A synonym for old,new,context';                },
                @{
                    ListItemText = 'context';
                    Tooltip      = 'Highlight whitespace errors in the context';                },
                @{
                    ListItemText = 'default';
                    Tooltip      = 'A synonym for new';                },
                @{
                    ListItemText = 'new';
                    Tooltip      = 'Highlight whitespace errors in the new lines of the diff';                },
                @{
                    ListItemText = 'old';
                    Tooltip      = 'Highlight whitespace errors in the old lines of the diff';                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
            },
            @{
                Line     = '--submodule=d';
                Expected = @{
                    ListItemText = 'diff';
                    Tooltip      = 'Shows an inline diff of the changed contents of the submodule';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
            },
            @{
                Line     = '--submodule=';
                Expected = @{
                    ListItemText = 'diff';
                    Tooltip      = 'Shows an inline diff of the changed contents of the submodule';
                },
                @{
                    ListItemText = 'log';
                    Tooltip      = 'Lists the commits in the range like "git submodule summary" does';
                },
                @{
                    ListItemText = 'short';
                    Tooltip      = '(default) Shows the names of the commits at the beginning and end of the range';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
            },
            @{
                Line     = '--diff-algorithm m';
                Expected = @{
                    ListItemText = 'minimal';
                    ToolTip      = 'Spend extra time to make sure the smallest possible diff is produced';
                },
                @{
                    ListItemText = 'myers';
                    ToolTip      = '(default) The basic greedy diff algorithm';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--diff-algorithm ';
                Expected = @{
                    ListItemText = 'histogram';
                    ToolTip      = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                },
                @{
                    ListItemText = 'minimal';
                    ToolTip      = 'Spend extra time to make sure the smallest possible diff is produced';
                },
                @{
                    ListItemText = 'myers';
                    ToolTip      = '(default) The basic greedy diff algorithm';
                },
                @{
                    ListItemText = 'patience';
                    ToolTip      = 'Use "patience diff" algorithm when generating patches';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--diff-algorithm=m';
                Expected = @{
                    CompletionText = "--diff-algorithm=minimal";
                    ListItemText   = 'minimal';
                    ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                },
                @{
                    CompletionText = "--diff-algorithm=myers";
                    ListItemText   = 'myers';
                    ToolTip        = '(default) The basic greedy diff algorithm';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
            },
            @{
                Line     = '--diff-algorithm=';
                Expected = @{
                    CompletionText = "--diff-algorithm=histogram";
                    ListItemText   = 'histogram';
                    ToolTip        = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                },
                @{
                    CompletionText = "--diff-algorithm=minimal";
                    ListItemText   = 'minimal';
                    ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                },
                @{
                    CompletionText = "--diff-algorithm=myers";
                    ListItemText   = 'myers';
                    ToolTip        = '(default) The basic greedy diff algorithm';
                },
                @{
                    CompletionText = "--diff-algorithm=patience";
                    ListItemText   = 'patience';
                    ToolTip        = 'Use "patience diff" algorithm when generating patches';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}