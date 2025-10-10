# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
        git config set pretty.changelog "format:* %H %s"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe '<Command>' -ForEach ('log', 'whatchanged' | ForEach-Object { @{Command = $_ } }) {
        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--quiet';
                        Right    = ' --';
                        Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
                    },
                    @{
                        Left     = '--quiet';
                        Right    = ' -- --all';
                        Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
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
                ListItemText = '-L';
                ToolTip      = "trace the evolution of line range <start>,<end> or function :<funcname> in <file>"
            },
            @{
                ListItemText = '-q';
                ToolTip      = "suppress diff output"
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
                    Line     = '--bi';
                    Expected = '--binary', '--bisect' | ConvertTo-Completion -ResultType ParameterName
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
                    Line     = '--ws-error-highlight d';
                    Expected = @{
                        ListItemText = 'default';
                        Tooltip      = 'A synonym for new';                    
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--ws-error-highlight ';
                    Expected = @{
                        ListItemText = 'all';
                        Tooltip      = 'A synonym for old,new,context';                    
                    },
                    @{
                        ListItemText = 'context';
                        Tooltip      = 'Highlight whitespace errors in the context';                    
                    },
                    @{
                        ListItemText = 'default';
                        Tooltip      = 'A synonym for new';                    
                    },
                    @{
                        ListItemText = 'new';
                        Tooltip      = 'Highlight whitespace errors in the new lines of the diff';                    
                    },
                    @{
                        ListItemText = 'old';
                        Tooltip      = 'Highlight whitespace errors in the old lines of the diff';                    
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--ws-error-highlight=d';
                    Expected = @{
                        ListItemText = 'default';
                        Tooltip      = 'A synonym for new';                    
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
                },
                @{
                    Line     = '--ws-error-highlight=';
                    Expected = @{
                        ListItemText = 'all';
                        Tooltip      = 'A synonym for old,new,context';                    
                    },
                    @{
                        ListItemText = 'context';
                        Tooltip      = 'Highlight whitespace errors in the context';                    
                    },
                    @{
                        ListItemText = 'default';
                        Tooltip      = 'A synonym for new';                    
                    },
                    @{
                        ListItemText = 'new';
                        Tooltip      = 'Highlight whitespace errors in the new lines of the diff';                    
                    },
                    @{
                        ListItemText = 'old';
                        Tooltip      = 'Highlight whitespace errors in the old lines of the diff';                    
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
                },
                @{
                    Line     = '--no-walk=u';
                    Expected = 'unsorted' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--no-walk=$_" }
                },
                @{
                    Line     = '--no-walk=';
                    Expected = 'sorted', 'unsorted' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--no-walk=$_" }
                },
                @{
                    Line     = '--diff-merges o';
                    Expected = 'off', 'on' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--diff-merges ';
                    Expected = '1', 'c', 'cc', 'combined', 'dense-combined', 'first-parent', 'm', 'none', 'off', 'on', 'r', 'remerge', 'separate' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--diff-merges=o';
                    Expected = 'off', 'on' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-merges=$_" }
                },
                @{
                    Line     = '--diff-merges=';
                    Expected = '1', 'c', 'cc', 'combined', 'dense-combined', 'first-parent', 'm', 'none', 'off', 'on', 'r', 'remerge', 'separate' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-merges=$_" }
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
                },
                @{
                    Line     = '--decorate=f';
                    Expected = 'full' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--decorate=$_" }
                },
                @{
                    Line     = '--decorate=';
                    Expected = 'full', 'short', 'no' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--decorate=$_" }
                },
                @{
                    Line     = '--date iso';
                    Expected = 'iso8601', 'iso8601-strict' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--date ';
                    Expected = 'auto:', 'default', 'format:', 'human', 'iso8601', 'iso8601-strict', 'local', 'raw', 'relative', 'rfc2822', 'short', 'unix' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--date=iso';
                    Expected = 'iso8601', 'iso8601-strict' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--date=$_" }
                },
                @{
                    Line     = '--date=';
                    Expected = 'auto:', 'default', 'format:', 'human', 'iso8601', 'iso8601-strict', 'local', 'raw', 'relative', 'rfc2822', 'short', 'unix' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--date=$_" }
                },
                @{
                    Line     = '--format=m';
                    Expected = 'mboxrd', 'medium' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
                },
                @{
                    Line     = '--format=';
                    Expected = @{
                        ListItemText = 'changelog';
                        Tooltip      = 'format:* %H %s';
                    },
                    'email', 'format:', 'full', 'fuller', 'mboxrd', 'medium',
                    'oneline', 'raw', 'reference', 'short', 'tformat:' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
                },
                @{
                    Line     = '--pretty=f';
                    Expected = 'format:', 'full', 'fuller' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--pretty=$_" }
                },
                @{
                    Line     = '--pretty=';
                    Expected = @{
                        ListItemText = 'changelog';
                        Tooltip      = 'format:* %H %s';
                    },
                    'email', 'format:', 'full', 'fuller', 'mboxrd', 'medium',
                    'oneline', 'raw', 'reference', 'short', 'tformat:' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--pretty=$_" }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist
    }
}