using namespace System.IO;

Describe 'RemoteOrRefspec' {
    It '<Line>' -ForEach @(
        @{
            Line     = '';
            Expected = @(
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial'
            ) | ConvertTo-Completion -ResultType ParameterValue
        },
        @{
            Line     = 'o';
            Expected = @(
                'ordinary/main',
                'origin/main'
            ) | ConvertTo-Completion -ResultType ParameterValue
        },
        @{
            Line     = '^';
            Expected = @(
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial'
            ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
        },
        @{
            Line     = '^o';
            Expected = @(
                'ordinary/main',
                'origin/main'
            ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
        },
        @{
            Line     = 'HEAD...';
            Expected = @(
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial'
            ) | ForEach-Object {
                "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD...$_"
            }
        },
        @{
            Line     = 'HEAD...o';
            Expected = @(
                'ordinary/main',
                'origin/main'
            ) | ForEach-Object {
                "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD...$_"
            }
        },
        @{
            Line     = 'HEAD..';
            Expected = @(
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial'
            ) | ForEach-Object {
                "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD..$_"
            }
        },
        @{
            Line     = 'HEAD..o';
            Expected = @(
                'ordinary/main',
                'origin/main'
            ) | ForEach-Object {
                "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD..$_"
            }
        }
    ) {
        "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
    }
}

Describe 'File' {
    It '<Line>' -ForEach @(
        @{
            Line     = 'brn..main:';
            Expected = @(
                'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object {
                    @{
                        File           = $_
                        CompletionText = "brn..main:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ProviderItem';
                    }
                })
        },
        @{
            Line     = 'brn..main:Pwsh/';
            Expected = @(
                @{
                    File           = 'Pwsh/world.ps1'
                    CompletionText = "brn..main:Pwsh/world.ps1";
                    ListItemText   = "world.ps1";
                    ResultType     = 'ProviderItem';
                }
            )
        },
        @{
            Line     = 'main:';
            Expected = 'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object { 
                @{
                    File           = $_
                    CompletionText = "main:$_";
                    ListItemText   = "$_";
                    ResultType     = 'ProviderItem';
                }
            }
        },
        @{
            Line     = 'main:Pws';
            Expected = 'Pwsh/' | ForEach-Object { 
                @{
                    File           = $_
                    CompletionText = "main:$_";
                    ListItemText   = "$_";
                    ResultType     = 'ProviderItem';
                }
            }
        },
        @{
            Line     = 'main:Pwsh/';
            Expected = @(
                @{
                    File           = 'Pwsh/world.ps1'
                    CompletionText = "main:Pwsh/world.ps1";
                    ListItemText   = "world.ps1";
                    ResultType     = 'ProviderItem';
                }
            )
        },
        @{
            Line     = 'main:Pwsh/wo';
            Expected = @(
                @{
                    File           = 'Pwsh/world.ps1'
                    CompletionText = "main:Pwsh/world.ps1";
                    ListItemText   = "world.ps1";
                    ResultType     = 'ProviderItem';
                }
            )
        },
        @{
            Line     = 'main:./Pwsh/';
            Expected = @(
                @{
                    File           = 'Pwsh/world.ps1'
                    CompletionText = "main:./Pwsh/world.ps1";
                    ListItemText   = "world.ps1";
                    ResultType     = 'ProviderItem';
                }
            )
        },
        @{
            Line     = 'main:./Pwsh/wo';
            Expected = @(
                @{
                    File           = 'Pwsh/world.ps1'
                    CompletionText = "main:./Pwsh/world.ps1";
                    ListItemText   = "world.ps1";
                    ResultType     = 'ProviderItem';
                }
            )
        }
    ) {
        foreach ($e in $expected) {
            $e.ToolTip = (Resolve-Path $e.File).Path.TrimEnd([Path]::AltDirectorySeparatorChar, [Path]::DirectorySeparatorChar)
        }
        "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
    }
}