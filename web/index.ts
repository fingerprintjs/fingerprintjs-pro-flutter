// Bundled `@fingerprint/agent` v4 loader for Flutter web.
// Custom endpoints go through `withoutDefault` so web behavior stays consistent
// with native platforms, which have no default fallback.
// https://docs.fingerprint.com/reference/js-agent-start-function
import * as Agent from "@fingerprint/agent";

type StartOptions = Parameters<typeof Agent.start>[0];

function start(options: StartOptions) {
  const { endpoints } = options;
  if (typeof endpoints !== "string" && !Array.isArray(endpoints)) {
    return Agent.start(options);
  }
  return Agent.start({
    ...options,
    endpoints: Agent.withoutDefault(endpoints),
  });
}

export const Fingerprint = {
  ...Agent,
  start,
};
