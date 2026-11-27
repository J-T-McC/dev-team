import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLlmsTxt from 'starlight-llms-txt';

const repo = 'https://github.com/J-T-McC/dev-team';

export default defineConfig({
  site: 'https://j-t-mcc.github.io',
  base: '/dev-team',
  // The board screenshots live in examples/board, outside the site folder.
  vite: { server: { fs: { allow: ['..'] } } },
  integrations: [
    starlight({
      title: 'dev-team',
      description:
        'A multi-agent Claude Code plugin that runs feature work like a small software team, in your own conversation or as parallel sessions on Orca.',
      social: [{ icon: 'github', label: 'GitHub', href: repo }],
      // Google Search Console ownership check.
      head: [
        {
          tag: 'meta',
          attrs: { name: 'google-site-verification', content: 'nqshZ9Z4f7QQO4C063Afx5z5lAFUKARzlbqOVNDjBEg' },
        },
      ],
      editLink: { baseUrl: `${repo}/edit/main/site/` },
      customCss: ['./src/styles/custom.css'],
      // llms.txt, llms-full.txt and llms-small.txt for agents, built from these pages.
      plugins: [
        starlightLlmsTxt({
          details: [
            'Install with `/plugin marketplace add J-T-McC/dev-team`, then `/plugin install dev-team@dev-team` and pick local scope (this project only; from a shell: `claude plugin install dev-team@dev-team --scope local`), and set up a project by asking Claude to set up dev-team (the `dev-team:bootstrap` skill).',
            "It runs two ways. By default every role runs inline in the user's own Claude Code conversation, one at a time, and a subagent starts only for parallel streams of work, an independent review, or a phase too big for the conversation: the low-token mode. Under the optional Orca runtime every role runs as its own top-level Claude Code session, never a subagent, several at once, and the user's session coordinates them; every task starts a fresh session, so it costs more.",
            "The roles write their documents (briefs or PRDs, designs, plans, ADRs, task files, reviews) into a workspace folder in the project's repo. The plugin brings no stack or tools of its own: every session runs on the project's CLAUDE.md, skills, plugins and MCP servers.",
          ].join('\n\n'),
          optionalLinks: [
            {
              label: 'README',
              url: 'https://raw.githubusercontent.com/J-T-McC/dev-team/main/README.md',
              description: 'the whole plugin on one page',
            },
            {
              label: 'Workflow rules',
              url: `${repo}/tree/main/workflow`,
              description: 'the rules the roles follow, one file per subject',
            },
          ],
        }),
      ],
      sidebar: [
        { label: 'Start here', items: ['getting-started', 'updating'] },
        {
          label: 'How it works',
          items: ['pipeline', 'roles', 'autonomy', 'workspace', 'team-rules', 'costs'],
        },
        { label: 'Optional', items: ['orca', 'orca-recommended', 'board', 'tickets', 'checkins'] },
        { label: 'Reference', items: ['reference/settings', 'reference/commands'] },
      ],
    }),
  ],
});
