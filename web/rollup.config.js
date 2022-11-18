const { join }  = require('path')
const typescript = require('@rollup/plugin-typescript')
const licensePlugin = require('rollup-plugin-license')
const { nodeResolve } = require('@rollup/plugin-node-resolve')
const { terser } = require ('rollup-plugin-terser')

const commonTerser = terser({
  format: {
    comments: false,
  },
  safari10: true,
})

const inputFile = 'src/index.ts'
const outputDirectory = 'dist'

const commonBanner = licensePlugin({
  banner: {
    content: {
      file: join(__dirname, 'resources', 'license_banner.txt'),
    },
  },
})

module.exports = {
    input: 'index.ts',
    // plugins: [typescript(), external(), commonBanner],
    plugins: [nodeResolve(), typescript()],
    output: [
      {
        name: 'FingerprintJSFlutter',
        exports: 'named',
        file: 'index.js',
        format: 'iife',
        plugins: [commonTerser],
      },
    ],
  }
