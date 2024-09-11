# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'GitAlias' -Tag Alias -Skip:$SkipHeavyTest {
    Describe '<Name>' -ForEach @(
        @{
            Name      = 'log'
            Setup     = [scriptblock] {
                git config set 'alias.log-oneline' 'log --oneline'
                git config set 'alias.log-all' 'log-oneline --all'
            }
            TestCases = @(
                @{
                    Line     = 'log-oneline --q';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 'log-all --q';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName
                }
            )
        },
        @{
            Name      = 'dsub'
            Setup     = [scriptblock] {
                git config set 'alias.dsub' 'config set diff.submodule'
            }
            TestCases = @(
                @{
                    Line     = 'dsub ';
                    Expected = 'diff', 'log', 'short' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'dsub d';
                    Expected = 'diff' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-c core.quotepath=false dsub d';
                    Expected = 'diff' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-c core.quotepath=true dsub d';
                    Expected = 'diff' | ConvertTo-Completion -ResultType ParameterValue
                }
            )
        },
        @{
            Name      = 'cnf'
            Setup     = [scriptblock] {
                git config set 'alias.cnf' 'config'
                git config set 'alias.ss' '"cnf" ''set'''
                git config set 'alias.dsub' 'ss diff.submodule'
            }
            TestCases = @(
                @{
                    Line     = 'cnf g';
                    Expected = @{
                        ListItemText = 'get';
                        ToolTip      = 'Emits the value of the specified key';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 'ss br';
                    Expected = 'branch.', 'browser.' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 'ss br';
                    Expected = 'branch.', 'browser.' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = 'dsub ';
                    Expected = 'diff', 'log', 'short' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'dsub d';
                    Expected = 'diff' | ConvertTo-Completion -ResultType ParameterValue
                }
            )
        },
        @{
            Name      = 'add'
            Setup     = [scriptblock] {
                git config set 'alias.al' 'add Logos '
            }
            TestCases = @(
                @{
                    Line     = 'al ';
                    Expected = 'Deava' | ConvertTo-Completion -ResultType ProviderItem
                }
            )
        }
    ) {
        BeforeAll {
            Initialize-Home
            mkdir ($rootPath = "$TestDrive/gitRoot")
            Push-Location $rootPath
            git init --initial-branch=main
            New-Item Deava
            New-Item Logos
        }

        AfterAll {
            Restore-Home
            Pop-Location
        }

        BeforeEach {
            . $Setup
        }

        It '<Line>' -ForEach $TestCases {
            "git $Line" | Complete-FromLine | Should -BeCompletion $Expected
        }
    }
}