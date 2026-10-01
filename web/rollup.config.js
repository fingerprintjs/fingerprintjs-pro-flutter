const typescript = require('@rollup/plugin-typescript')
const { nodeResolve } = require('@rollup/plugin-node-resolve')
const { terser } = require ('rollup-plugin-terser')

const commonTerser = terser({
  format: {
    // Keep only the `/*!` banner below.
    comments: /^!/,
  },
  safari10: true,
})

// Terser strips all comments, including the agent's own copyright header.
// The agent is not MIT (see its LICENSE), so the bundle needs a notice.
const agentVersion = require('@fingerprint/agent/package.json').version
const banner = `/*!
 * fingerprint_flutter web loader - Copyright (c) FingerprintJS, Inc, ${new Date().getFullYear()} (https://fingerprint.com)
 * Licensed under the MIT license. Bundles @fingerprint/agent v${agentVersion},
 * licensed under https://dev.fingerprint.com/docs/terms-of-service
 */`

module.exports = {
    input: 'index.ts',
    plugins: [nodeResolve(), typescript()],
    output: [
      {
        name: 'FingerprintFlutter',
        exports: 'named',
        file: 'index.js',
        format: 'iife',
        banner,
        plugins: [commonTerser],
      },
    ],
  }
