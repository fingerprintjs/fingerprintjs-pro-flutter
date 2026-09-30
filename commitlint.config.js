// Commit message rules, checked on PRs and by the local commit-msg hook.
// Squash merges use the PR title as the subject, so accept the shapes PR titles often have:
// - any subject case ("feat: Add X")
// - a ticket ID in place of the type ("INTER-123: add X")
// Releases come from changesets, not commit types, so a loose type is safe.
// https://commitlint.js.org/reference/rules.html
module.exports = {
  extends: ['@fingerprintjs/commit-lint-dx-team'],
  parserPreset: {
    parserOpts: {
      headerPattern: /^(\w+|[A-Z]+-\d+)(?:\((.*)\))?!?: (.*)$/,
      breakingHeaderPattern: /^(\w+|[A-Z]+-\d+)(?:\((.*)\))?!: (.*)$/,
    },
  },
  rules: {
    'subject-case': [0],
    'type-case': [0],
    'type-enum': [0],
  },
};
