import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

const repo = 'https://github.com/J-T-McC/dev-team';

export default defineConfig({
  site: 'https://j-t-mcc.github.io',
  base: '/dev-team',
  // The board screenshots live in examples/board, outside the site folder.
  vite: { server: { fs: { allow: ['..'] } } },
  integrations: [
    starlight({
      title: 'dev-team',
      description: 'A Claude Code plugin that runs feature work like a small software team.',
      social: [{ icon: 'github', label: 'GitHub', href: repo }],
      editLink: { baseUrl: `${repo}/edit/main/site/` },
      customCss: ['./src/styles/custom.css'],
      sidebar: [
        { label: 'Start here', items: ['getting-started', 'updating'] },
        {
          label: 'How it works',
          items: ['pipeline', 'roles', 'autonomy', 'workspace', 'team-rules'],
        },
        { label: 'Optional', items: ['orca', 'orca-recommended', 'board', 'tickets', 'checkins'] },
        { label: 'Reference', items: ['reference/settings', 'reference/commands'] },
      ],
    }),
  ],
});
