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
                    Expected = '--bisect', '--binary' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-p';
                    Expected = '--no-prefix', '--no-patch' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'OptionValue' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--ws-error-highlight d';
                    Expected = 'default' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--ws-error-highlight ';
                    Expected = 'context', 'old', 'new', 'all', 'default' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--ws-error-highlight=d';
                    Expected = 'default' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
                },
                @{
                    Line     = '--ws-error-highlight=';
                    Expected = 'context', 'old', 'new', 'all', 'default' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
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
                    Expected = 'off', 'none', 'on', 'first-parent', '1', 'separate', 'm', 'combined', 'c', 'dense-combined', 'cc', 'remerge', 'r' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--diff-merges=o';
                    Expected = 'off', 'on' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-merges=$_" }
                },
                @{
                    Line     = '--diff-merges=';
                    Expected = 'off', 'none', 'on', 'first-parent', '1', 'separate', 'm', 'combined', 'c', 'dense-combined', 'cc', 'remerge', 'r' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-merges=$_" }
                },
                @{
                    Line     = '--submodule=d';
                    Expected = 'diff' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
                },
                @{
                    Line     = '--submodule=';
                    Expected = 'diff', 'log', 'short' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
                },
                @{
                    Line     = '--diff-algorithm m';
                    Expected = 'myers', 'minimal' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--diff-algorithm ';
                    Expected = 'myers', 'minimal', 'patience', 'histogram' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--diff-algorithm=m';
                    Expected = 'myers', 'minimal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
                },
                @{
                    Line     = '--diff-algorithm=';
                    Expected = 'myers', 'minimal', 'patience', 'histogram' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
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
                    Expected = 'relative', 'iso8601', 'iso8601-strict', 'rfc2822', 'short', 'local', 'default', 'human', 'raw', 'unix', 'auto:', 'format:' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--date=iso';
                    Expected = 'iso8601', 'iso8601-strict' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--date=$_" }
                },
                @{
                    Line     = '--date=';
                    Expected = 'relative', 'iso8601', 'iso8601-strict', 'rfc2822', 'short', 'local', 'default', 'human', 'raw', 'unix', 'auto:', 'format:' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--date=$_" }
                },
                @{
                    Line     = '--format=m';
                    Expected = 'medium', 'mboxrd' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
                },
                @{
                    Line     = '--format=';
                    Expected = 'oneline', 'short', 'medium', 'full', 'fuller', 'reference', 'email', 'raw', 'format:', 'tformat:', 'mboxrd', 'changelog' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
                },
                @{
                    Line     = '--pretty=f';
                    Expected = 'full', 'fuller', 'format:' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--pretty=$_" }
                },
                @{
                    Line     = '--pretty=';
                    Expected = 'oneline', 'short', 'medium', 'full', 'fuller', 'reference', 'email', 'raw', 'format:', 'tformat:', 'mboxrd', 'changelog' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--pretty=$_" }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist
    }
}