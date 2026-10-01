const typescript = require('@rollup/plugin-typescript')
const { nodeResolve } = require('@rollup/plugin-node-resolve')
const { terser } = require ('rollup-plugin-terser')

const commonTerser = terser({
  format: {
    comments: false,
  },
  safari10: true,
})

module.exports = {
    input: 'index.ts',
    plugins: [nodeResolve(), typescript()],
    output: [
      {
        name: 'FingerprintFlutter',
        exports: 'named',
        file: 'index.js',
        format: 'iife',
        plugins: [commonTerser],
      },
    ],
  }
