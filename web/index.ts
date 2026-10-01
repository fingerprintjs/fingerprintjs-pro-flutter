// Bundled `@fingerprint/agent` v4 loader for Flutter web.
// Custom endpoints go through `withoutDefault` so web behavior stays consistent
// with native platforms, which have no default fallback.
// https://docs.fingerprint.com/reference/js-agent-start-function
import { start as agentStart, withoutDefault } from "@fingerprint/agent";

type StartOptions = Parameters<typeof agentStart>[0];

// Dart sends endpoints only as a list.
function start(options: StartOptions) {
  const { endpoints } = options;
  if (!Array.isArray(endpoints)) {
    return agentStart(options);
  }
  return agentStart({ ...options, endpoints: withoutDefault(endpoints) });
}

// Dart reads only `start`. Exporting nothing else keeps unused agent code
// out of the bundle.
export const Fingerprint = { start };
