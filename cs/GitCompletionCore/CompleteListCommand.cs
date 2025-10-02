using System.Management.Automation;

namespace Kzrnm.GitCompletion;

[Cmdlet(VerbsLifecycle.Complete, "List")]
[CmdletBinding(PositionalBinding = false)]
[OutputType([typeof(CompletionResult[])])]
public class CompleteListCommand : PSCmdlet
{
#nullable disable
    [Parameter]
    [AllowEmptyString]
    public string Current { get; set; } = "";

    [Parameter]
    [AllowEmptyString]
    public string Prefix { get; set; } = "";

    [Parameter]
    public string Suffix { get; set; } = "";

    [Parameter]
    public ScriptBlock DescriptionBuilder { get; set; }

    [Parameter]
    public string[] Messages { get; set; }

    [Parameter]
    public CompletionResultType ResultType { get; set; } = CompletionResultType.ParameterName;

    [Parameter(ParameterSetName = "Prefix")]
    public SwitchParameter RemovePrefix { get; set; }

    [Parameter]
    public HashSet<string> Exclude { get; set; }

    [Parameter(ValueFromPipeline = true)]
    public string Candidate { get; set; }

    int count;
#nullable restore

    protected override void BeginProcessing()
    {
        count = 0;
        if (RemovePrefix && Current.StartsWith(Prefix))
        {
            Current = Current.Substring(Prefix.Length);
        }
        Exclude ??= [];

        base.BeginProcessing();
    }

    protected override void ProcessRecord()
    {
        ProcessRecordCore();
        base.ProcessRecord();
    }
    private void ProcessRecordCore()
    {
        if (!string.IsNullOrEmpty(Current) && !Candidate.StartsWith(Current))
            return;

        if (!Exclude.Add(Candidate))
            return;

        string? desc = null;
        if (Messages is { } messages)
        {
            int count = this.count;
            if ((uint)count < (uint)messages.Length)
            {
                desc = messages[count];
            }
            this.count++;
        }
        else if (DescriptionBuilder is { } descriptionBuilder)
        {
            desc = descriptionBuilder.InvokeWithContext(null, [new("_", Candidate)], Candidate).FirstOrDefault()
                ?.BaseObject as string;
        }

        desc ??= Candidate;

        var completion = $"{Prefix}{Candidate}{Suffix}";
        WriteObject(new CompletionResult(completion, Candidate, ResultType, desc));
    }
}
