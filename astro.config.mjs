import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://AKtzone.github.io',
  base: '/WEB',
  outDir: './dist',

  // 自动生成 sitemap
  integrations: [sitemap({
    changefreq: 'weekly',
    priority: 0.7,
    lastmod: new Date(),
  })],

  // shiki 代码高亮配置
  markdown: {
    syntaxHighlight: 'shiki',
    shikiConfig: {
      // 选择主题：dark 模式用 one-dark-pro
      theme: 'one-dark-pro',
      // 支持的语言（默认已支持大部分常见语言）
      // 启用行号
      // wrap: true,
    },
  },
});
