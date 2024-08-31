using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
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

    It 'ShortOptions' {
        $expected = @(
            @{
                CompletionText = '-a';
                ListItemText   = '-a';
                ResultType     = 'ParameterName';
                ToolTip        = "treat all files as text";
            },
            @{
                CompletionText = '-b';
                ListItemText   = '-b';
                ResultType     = 'ParameterName';
                ToolTip        = "ignore changes in amount of whitespace";
            },
            @{
                CompletionText = '-B';
                ListItemText   = '-B';
                ResultType     = 'ParameterName';
                ToolTip        = "break complete rewrite changes into pairs of delete and create";
            },
            @{
                CompletionText = '-C';
                ListItemText   = '-C';
                ResultType     = 'ParameterName';
                ToolTip        = "detect copies";
            },
            @{
                CompletionText = '-D';
                ListItemText   = '-D';
                ResultType     = 'ParameterName';
                ToolTip        = "omit the preimage for deletes";
            },
            @{
                CompletionText = '-G';
                ListItemText   = '-G';
                ResultType     = 'ParameterName';
                ToolTip        = "look for differences that change the number of occurrences of the specified regex";
            },
            @{
                CompletionText = '-I';
                ListItemText   = '-I';
                ResultType     = 'ParameterName';
                ToolTip        = "ignore changes whose all lines match <regex>";
            },
            @{
                CompletionText = '-l';
                ListItemText   = '-l';
                ResultType     = 'ParameterName';
                ToolTip        = "prevent rename/copy detection if the number of rename/copy targets exceeds given limit";
            },
            @{
                CompletionText = '-M';
                ListItemText   = '-M';
                ResultType     = 'ParameterName';
                ToolTip        = "detect renames";
            },
            @{
                CompletionText = '-O';
                ListItemText   = '-O';
                ResultType     = 'ParameterName';
                ToolTip        = "control the order in which files appear in the output";
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "generate patch";
            },
            @{
                CompletionText = '-R';
                ListItemText   = '-R';
                ResultType     = 'ParameterName';
                ToolTip        = "swap two inputs, reverse the diff";
            },
            @{
                CompletionText = '-s';
                ListItemText   = '-s';
                ResultType     = 'ParameterName';
                ToolTip        = "suppress diff output";
            },
            @{
                CompletionText = '-S';
                ListItemText   = '-S';
                ResultType     = 'ParameterName';
                ToolTip        = "look for differences that change the number of occurrences of the specified string";
            },
            @{
                CompletionText = '-u';
                ListItemText   = '-u';
                ResultType     = 'ParameterName';
                ToolTip        = "generate patch";
            },
            @{
                CompletionText = '-U';
                ListItemText   = '-U';
                ResultType     = 'ParameterName';
                ToolTip        = "generate diffs with <n> lines context";
            },
            @{
                CompletionText = '-w';
                ListItemText   = '-w';
                ResultType     = 'ParameterName';
                ToolTip        = "ignore whitespace when comparing lines";
            },
            @{
                CompletionText = '-W';
                ListItemText   = '-W';
                ResultType     = 'ParameterName';
                ToolTip        = "generate diffs with <n> lines context";
            },
            @{
                CompletionText = '-X';
                ListItemText   = '-X';
                ResultType     = 'ParameterName';
                ToolTip        = "output the distribution of relative amount of changes for each sub-directory";
            },
            @{
                CompletionText = '-z';
                ListItemText   = '-z';
                ResultType     = 'ParameterName';
                ToolTip        = "do not munge pathnames and use NULs as output field terminators in --raw or --numstat";
            },
            @{
                CompletionText = '-h';
                ListItemText   = '-h';
                ResultType     = 'ParameterName';
                ToolTip        = "show help";
            }
        )
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--r';
                Expected = '--relative', '--raw' | ForEach-Object { 
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterName';
                        ToolTip        = "$_"
                    }
                }
            },
            @{
                Line     = '--cr';
                Expected = '--creation-factor=' | ForEach-Object { 
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterName';
                        ToolTip        = "$_"
                    }
                }
            },
            @{
                Line     = '--no-d';
                Expected = '--no-dual-color' | ForEach-Object { 
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterName';
                        ToolTip        = "$_"
                    }
                }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Revlist' {
        . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_Revlist.ps1"
    }
}