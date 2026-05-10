import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    description: z.string(),
    tags: z.array(z.string()),
    // 草稿标记：true = 草稿（不公开发布），false/undefined = 已发布
    draft: z.boolean().optional().default(false),
  }),
});

const projects = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    description: z.string(),
    tech: z.array(z.string()),
    url: z.string().optional(),
    // github 字段已移除
  }),
});

export const collections = { blog, projects };
