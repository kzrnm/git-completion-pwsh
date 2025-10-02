using System.Diagnostics;
using System.Management.Automation;
using System.Management.Automation.Language;
using System.Management.Automation.Runspaces;

namespace Kzrnm.GitCompletion;

[Cmdlet(VerbsLifecycle.Complete, "GitCore")]
[CmdletBinding(PositionalBinding = false)]
[OutputType([typeof(CompletionResult[])])]
public class CompleteGitCoreCommand : PSCmdlet
{
#nullable disable
    [Parameter(Mandatory = true, ParameterSetName = "String")]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    public string[] Words { get; set; }

    [Parameter(ParameterSetName = "String")]
    public int CurrentIndex { get; set; } = -1;



    [Parameter(Mandatory = true, ParameterSetName = "Ast")]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    public CommandAst CommandAst { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "Ast")]
    public int CursorPosition { get; set; }

    PowerShell ps;
#nullable restore

    protected override void BeginProcessing()
    {
        ps = PowerShell.Create(RunspaceMode.CurrentRunspace);
        base.BeginProcessing();
    }

    protected override void EndProcessing()
    {
        var list1 = new List<string>();
        var list2 = new List<string>();

        var sw1 = Stopwatch.StartNew();

        for (int i = 0; i < 8; i++)
        {
            //var lines = InvokeCommand.InvokeScript("git log --oneline -20");

            ps.Commands.Clear();
            var lines = ps.AddCommand("git").AddArgument("log").AddArgument("--oneline").AddArgument("-20").Invoke();

            // 実行して結果を取得
            foreach (var item in lines)
                list1.Add((string)item.BaseObject);
        }

        sw1.Stop();

        WriteObject("----");

        var sw2 = Stopwatch.StartNew();

        for (int i = 0; i < 8; i++)
        {
            using var ps = Process.Start(new ProcessStartInfo("C:\\Program Files\\Git\\cmd\\git.exe", "log --oneline -20")
            {
                RedirectStandardOutput = true,
            });
            while (ps.StandardOutput.ReadLine() is not null and var line)
            {
                list2.Add(line);
            }
        }
        sw2.Stop();
        WriteObject(new CompletionResult("git"));

        ps.Dispose();
        base.EndProcessing();
    }
}

/*

function Complete-Git {

    if ($PSCmdlet.ParameterSetName -eq 'Ast') {
        $Words, $CurrentIndex = buildWords $CommandAst $CursorPosition
    }

    if ($CurrentIndex -lt 0) { $CurrentIndex = $Words.Length - 1 }
    return Complete-GitCommandLine ([CommandLineContext]::new($Words, $CurrentIndex))
}
 */
