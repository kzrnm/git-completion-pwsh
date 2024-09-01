using namespace System.Collections.Generic;

. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-d';
            ToolTip      = "delete symbolic ref";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "reason of the update";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "suppress error message for non-symbolic (detached) refs";
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
                Line     = '--r';
                Expected = @{
                    ListItemText = '--recurse';
                    ToolTip      = "recursively dereference (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-';
                Expected = @{
                    ListItemText = '--no-quiet';
                    ToolTip      = "[NO] suppress error message for non-symbolic (detached) refs";
                },
                @{
                    ListItemText = '--no-delete';
                    ToolTip      = "[NO] delete symbolic ref";
                } ,
                @{
                    ListItemText = '--no-short';
                    ToolTip      = "[NO] shorten ref output";
                } ,
                @{
                    ListItemText = '--no-recurse';
                    ToolTip      = "[NO] recursively dereference (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-quiet';
                    ToolTip      = "[NO] suppress error message for non-symbolic (detached) refs";
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

    Describe 'Revlist' {
        . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/Revlist.ps1" -Ref
    }
}