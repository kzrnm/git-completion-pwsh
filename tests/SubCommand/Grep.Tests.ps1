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
                    Left     = '--textconv';
                    Right    = ' --';
                    Expected = '--textconv' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'process binary files with textconv filters'
                },
                @{
                    Left     = '--textconv';
                    Right    = ' -- --all';
                    Expected = '--textconv' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'process binary files with textconv filters'
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
                Line     = '-- ';
                Expected = @()
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-0';
            ToolTip      = "shortcut for -C 0";
        },
        @{
            ListItemText = '-1';
            ToolTip      = "shortcut for -C 1";
        },
        @{
            ListItemText = '-2';
            ToolTip      = "shortcut for -C 2";
        },
        @{
            ListItemText = '-3';
            ToolTip      = "shortcut for -C 3";
        },
        @{
            ListItemText = '-4';
            ToolTip      = "shortcut for -C 4";
        },
        @{
            ListItemText = '-5';
            ToolTip      = "shortcut for -C 5";
        },
        @{
            ListItemText = '-6';
            ToolTip      = "shortcut for -C 6";
        },
        @{
            ListItemText = '-7';
            ToolTip      = "shortcut for -C 7";
        },
        @{
            ListItemText = '-8';
            ToolTip      = "shortcut for -C 8";
        },
        @{
            ListItemText = '-9';
            ToolTip      = "shortcut for -C 9";
        },
        @{
            ListItemText = '-a';
            ToolTip      = "process binary files as text";
        },
        @{
            ListItemText = '-A';
            ToolTip      = "show <n> context lines after matches";
        },
        @{
            ListItemText = '-B';
            ToolTip      = "show <n> context lines before matches";
        },
        @{
            ListItemText = '-c';
            ToolTip      = "show the number of matches instead of matching lines";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "show <n> context lines before and after matches";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "match <pattern>";
        },
        @{
            ListItemText = '-E';
            ToolTip      = "use extended POSIX regular expressions";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "read patterns from file";
        },
        @{
            ListItemText = '-F';
            ToolTip      = "interpret patterns as fixed strings";
        },
        @{
            ListItemText = '-G';
            ToolTip      = "use basic POSIX regular expressions (default)";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "don't show filenames";
        },
        @{
            ListItemText = '-H';
            ToolTip      = "show filenames";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "case insensitive matching";
        },
        @{
            ListItemText = '-I';
            ToolTip      = "don't match patterns in binary files";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "show only filenames instead of matching lines";
        },
        @{
            ListItemText = '-L';
            ToolTip      = "show only the names of files without match";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "maximum number of results per file";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "show line numbers";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "show only matching parts of a line";
        },
        @{
            ListItemText = '-O';
            ToolTip      = "show matching files in the pager";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "show a line with the function name before matches";
        },
        @{
            ListItemText = '-P';
            ToolTip      = "use Perl-compatible regular expressions";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "indicate hit with exit status without output";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "search in subdirectories (default)";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "show non-matching lines";
        },
        @{
            ListItemText = '-w';
            ToolTip      = "match patterns only at word boundaries";
        },
        @{
            ListItemText = '-W';
            ToolTip      = "show the surrounding function";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "print NUL after filenames";
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
                    ListItemText = '--after-context=';
                    ToolTip      = "show <n> context lines after matches";
                },
                @{
                    ListItemText = '--and';
                    ToolTip      = "combine patterns specified with -e";
                },
                @{
                    ListItemText = '--all-match';
                    ToolTip      = "show only matches from files that match all patterns";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--q';
                Expected = @{
                    ListItemText = '--quiet';
                    ToolTip      = "indicate hit with exit status without output";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-a';
                Expected = @{
                    ListItemText = '--no-after-context';
                    ToolTip      = "[NO] show <n> context lines after matches";
                },
                @{
                    ListItemText = '--no-all-match';
                    ToolTip      = "[NO] show only matches from files that match all patterns";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-i';
                Expected = @{
                    ListItemText = '--no-index';
                    ToolTip      = "find in contents not managed by git";
                },
                @{
                    ListItemText = '--no-invert-match';
                    ToolTip      = "[NO] show non-matching lines";
                },
                @{
                    ListItemText = '--no-ignore-case';
                    ToolTip      = "[NO] case insensitive matching";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-index';
                    ToolTip      = "find in contents not managed by git";
                },
                @{
                    ListItemText = '--not';
                    ToolTip      = "combine patterns specified with -e";
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

    Describe-Revlist -Ref
}