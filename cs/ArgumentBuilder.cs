// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Diagnostics;
using System.Text;

namespace Kzrnm.GitCompletion;
internal static class ArgumentBuilder
{
    [DebuggerStepThrough]
    public static void AppendArgument(this StringBuilder sb, string argument, int start = 0)
    {
        sb.Append('"');
        for (int i = start; i < argument.Length;)
        {
            char c = argument[i++];
            if (c == '\\')
            {
                int numBackSlash = 1;
                while (i < argument.Length && argument[i] == '\\')
                {
                    i++;
                    numBackSlash++;
                }

                if (i == argument.Length)
                {
                    sb.Append('\\', numBackSlash * 2);
                }
                else if (argument[i] == '"')
                {
                    sb.Append('\\', numBackSlash * 2 + 1);
                    sb.Append('"');
                    i++;
                }
                else
                {
                    sb.Append('\\', numBackSlash);
                }

                continue;
            }

            if (c == '"')
            {
                sb.Append('\\');
            }

            sb.Append(c);
        }
        sb.Append('"');
    }
}
