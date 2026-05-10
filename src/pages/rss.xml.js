import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog');
  const sortedPosts = posts
    .filter(post => !post.data.draft)  // 排除草稿
    .sort((a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime());

  return rss({
    title: 'ZONE 的博客',
    description: '探索技术与创意的无限可能',
    site: context.site + '/WEB',  // 注意 base 路径
    items: sortedPosts.map(post => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.description,
      link: `/WEB/blog/${post.slug}/`,
    })),
    customData: `<language>zh-CN</language>`,
  });
}
