# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
    }

    Describe 'Subcommands' {
        It '<Line>' -ForEach @(
            @{
                Line     = ""
                Expected =
                'init',
                'fetch',
                'clone',
                'rebase',
                'dcommit',
                'log',
                'find-rev',
                'set-tree',
                'commit-diff',
                'info',
                'create-ignore',
                'propget',
                'proplist',
                'show-ignore',
                'show-externals',
                'branch',
                'tag',
                'blame',
                'migrate',
                'mkdirs',
                'reset',
                'gc' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = "re"
                Expected =
                'rebase', 'reset' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'fetch' {
        BeforeAll {
            Set-Variable Subcommand 'fetch'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--revision=',
                    '--fetch-all',
                    '--follow-parent',
                    '--authors-file=',
                    '--repack=',
                    '--no-metadata',
                    '--use-svm-props',
                    '--use-svnsync-props',
                    '--log-window-size=',
                    '--no-checkout',
                    '--quiet',
                    '--repack-flags',
                    '--use-log-author',
                    '--localtime',
                    '--add-author-from',
                    '--recursive',
                    '--ignore-paths=',
                    '--include-paths=',
                    '--username=',
                    '--config-dir=',
                    '--no-auth-cache' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }


    Describe 'clone' {
        BeforeAll {
            Set-Variable Subcommand 'clone'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--revision=',
                    '--follow-parent',
                    '--authors-file=',
                    '--repack=',
                    '--no-metadata',
                    '--use-svm-props',
                    '--use-svnsync-props',
                    '--log-window-size=',
                    '--no-checkout',
                    '--quiet',
                    '--repack-flags',
                    '--use-log-author',
                    '--localtime',
                    '--add-author-from',
                    '--recursive',
                    '--ignore-paths=',
                    '--include-paths=',
                    '--username=',
                    '--config-dir=',
                    '--no-auth-cache',
                    '--template=',
                    '--shared=',
                    '--trunk=',
                    '--tags=',
                    '--branches=',
                    '--stdlayout',
                    '--minimize-url',
                    '--rewrite-root=',
                    '--prefix=' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected =
                    '--quiet' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'init' {
        BeforeAll {
            Set-Variable Subcommand 'init'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--template=',
                    '--shared=',
                    '--trunk=',
                    '--tags=',
                    '--branches=',
                    '--stdlayout',
                    '--minimize-url',
                    '--no-metadata',
                    '--use-svm-props',
                    '--use-svnsync-props',
                    '--rewrite-root=',
                    '--prefix=',
                    '--username=',
                    '--config-dir=',
                    '--no-auth-cache' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--p';
                    Expected =
                    '--prefix=' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'dcommit' {
        BeforeAll {
            Set-Variable Subcommand 'dcommit'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--merge',
                    '--strategy=',
                    '--verbose',
                    '--dry-run',
                    '--fetch-all',
                    '--no-rebase',
                    '--commit-url',
                    '--revision',
                    '--interactive',
                    '--edit',
                    '--rmdir',
                    '--find-copies-harder',
                    '--copy-similarity=',
                    '--follow-parent',
                    '--authors-file=',
                    '--repack=',
                    '--no-metadata',
                    '--use-svm-props',
                    '--use-svnsync-props',
                    '--log-window-size=',
                    '--no-checkout',
                    '--quiet',
                    '--repack-flags',
                    '--use-log-author',
                    '--localtime',
                    '--add-author-from',
                    '--recursive',
                    '--ignore-paths=',
                    '--include-paths=',
                    '--username=',
                    '--config-dir=',
                    '--no-auth-cache' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected =
                    '--quiet' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'set-tree' {
        BeforeAll {
            Set-Variable Subcommand 'set-tree'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--stdin',
                    '--edit',
                    '--rmdir',
                    '--find-copies-harder',
                    '--copy-similarity=',
                    '--follow-parent',
                    '--authors-file=',
                    '--repack=',
                    '--no-metadata',
                    '--use-svm-props',
                    '--use-svnsync-props',
                    '--log-window-size=',
                    '--no-checkout',
                    '--quiet',
                    '--repack-flags',
                    '--use-log-author',
                    '--localtime',
                    '--add-author-from',
                    '--recursive',
                    '--ignore-paths=',
                    '--include-paths=',
                    '--username=',
                    '--config-dir=',
                    '--no-auth-cache' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected =
                    '--quiet' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'rebase' {
        BeforeAll {
            Set-Variable Subcommand 'rebase'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--merge',
                    '--verbose',
                    '--strategy=',
                    '--local',
                    '--fetch-all',
                    '--dry-run',
                    '--follow-parent',
                    '--authors-file=',
                    '--repack=',
                    '--no-metadata',
                    '--use-svm-props',
                    '--use-svnsync-props',
                    '--log-window-size=',
                    '--no-checkout',
                    '--quiet',
                    '--repack-flags',
                    '--use-log-author',
                    '--localtime',
                    '--add-author-from',
                    '--recursive',
                    '--ignore-paths=',
                    '--include-paths=',
                    '--username=',
                    '--config-dir=',
                    '--no-auth-cache' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected =
                    '--quiet' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'commit-diff' {
        BeforeAll {
            Set-Variable Subcommand 'commit-diff'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--message=',
                    '--file=',
                    '--revision=',
                    '--edit',
                    '--rmdir',
                    '--find-copies-harder',
                    '--copy-similarity=' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--e';
                    Expected =
                    '--edit' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'log' {
        BeforeAll {
            Set-Variable Subcommand 'log'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--limit=',
                    '--revision=',
                    '--verbose',
                    '--incremental',
                    '--oneline',
                    '--show-commit',
                    '--non-recursive',
                    '--authors-file=',
                    '--color' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--v';
                    Expected =
                    '--verbose' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'info' {
        BeforeAll {
            Set-Variable Subcommand 'info'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--url' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--u';
                    Expected =
                    '--url' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'branch' {
        BeforeAll {
            Set-Variable Subcommand 'branch'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--dry-run',
                    '--message',
                    '--tag' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--t';
                    Expected =
                    '--tag' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'tag' {
        BeforeAll {
            Set-Variable Subcommand 'tag'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--dry-run',
                    '--message' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--m';
                    Expected =
                    '--message' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'blame' {
        BeforeAll {
            Set-Variable Subcommand 'blame'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--git-format' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--g';
                    Expected =
                    '--git-format' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'migrate' {
        BeforeAll {
            Set-Variable Subcommand 'migrate'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--config-dir=',
                    '--ignore-paths=',
                    '--minimize',
                    '--no-auth-cache',
                    '--username=' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--u';
                    Expected =
                    '--username=' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'reset' {
        BeforeAll {
            Set-Variable Subcommand 'reset'
        }
        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected =
                    '--revision=',
                    '--parent' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--p';
                    Expected =
                    '--parent' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe '<Subcommand>' -ForEach @(
        'create-ignore',
        'propget',
        'proplist',
        'show-ignore',
        'show-externals',
        'mkdirs' | ForEach-Object { @{Subcommand = $_ } }) {
        Describe 'Options' { It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = '--revision=' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--rev';
                    Expected = '--revision=' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}