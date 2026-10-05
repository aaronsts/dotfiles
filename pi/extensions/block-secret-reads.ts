import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

const secretPath =
  /(?:^|\/)(?:\.env(?!\.(?:example|sample|template)(?:\.[^/]*)?(?:$|\/))(?:\.[^/]*)?|\.envrc|\.netrc|\.npmrc|\.pypirc|\.pgpass|(?:secret|secrets|credential|credentials)(?:\.[^/]*)?|id_(?:rsa|dsa|ecdsa|ed25519)(?:\.pub)?|authorized_keys|known_hosts)(?:$|\/)|\.(?:pem|key|p12|pfx|jks)$/i;

function isSecretPath(value: string) {
  return secretPath.test(value.replaceAll("\\", "/"));
}

function commandMentionsSecret(command: string) {
  return command
    .split(/[\s"'`=;|&()]+/)
    .some((value) => isSecretPath(value));
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (isToolCallEventType("read", event) && isSecretPath(event.input.path)) {
      return {
        block: true,
        reason: "Blocked: agents are not authorized to read files that may contain secrets.",
      };
    }

    if (
      isToolCallEventType("bash", event) &&
      commandMentionsSecret(event.input.command)
    ) {
      return {
        block: true,
        reason: "Blocked: agents are not authorized to read files that may contain secrets.",
      };
    }
  });
}
