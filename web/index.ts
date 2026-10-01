// Bundled `@fingerprint/agent` v4 loader for Flutter web.
// Custom endpoints go through `withoutDefault` so web behavior stays consistent
// with native platforms, which have no default fallback.
// https://docs.fingerprint.com/reference/js-agent-start-function
import { start as agentStart, withoutDefault } from "@fingerprint/agent";

type StartOptions = Parameters<typeof agentStart>[0];

// Dart sends endpoints only as a list. Dart reads only `start`, so nothing
// else is exported, which keeps unused agent code out of the bundle.
function start(options: StartOptions) {
  const { endpoints } = options;
  if (!Array.isArray(endpoints)) {
    return agentStart(options);
  }
  return agentStart({ ...options, endpoints: withoutDefault(endpoints) });
}

export const Fingerprint = { start };
