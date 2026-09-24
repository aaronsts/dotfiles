import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

const blockedGitCommand =
  /\bgit(?:\s+(?:-C|--git-dir|--work-tree|--namespace|-c|--config-env)\s+\S+|\s+--?[\w-]+(?:=\S+)?)*\s+(?:commit|push)\b/;

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (!isToolCallEventType("bash", event)) return;

    if (blockedGitCommand.test(event.input.command)) {
      return {
        block: true,
        reason:
          "Blocked: agents are not authorized to run git commit or git push. The user performs these actions.",
      };
    }
  });
}
