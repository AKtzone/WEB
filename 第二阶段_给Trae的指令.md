# 第二阶段改进 — 给 Trae 的执行指令

> 项目路径：D:\Project\WEB
> 技术栈：Astro 5.x + TypeScript + CSS
> 部署：GitHub Pages（base: /WEB）

---

## 任务 1：暗色/亮色模式切换

### 改动文件
1. `src/styles/global.css`
2. `src/components/Header.astro`

### 具体实现

#### 步骤 1 — 在 global.css 的 :root 添加亮色主题

在现有的 `:root` 后面（`--gradient-text-alt` 变量之后），添加 `[data-theme="light"]` 选择器：

```css
/* 亮色主题 */
[data-theme="light"] {
  --primary: #7c3aed;
  --primary-hover: #6d28d9;
  --secondary: #db2777;
  --bg: #ffffff;
  --bg-secondary: #f5f3ff;
  --bg-card: #ffffff;
  --text: #1e1b4b;
  --text-secondary: #6b7280;
  --border: #e5e7eb;
  --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 20px rgba(124, 58, 237, 0.2);
  --gradient-bg: linear-gradient(180deg, #ffffff 0%, #f5f3ff 50%, #ffffff 100%);
}

/* 亮色主题下毛玻璃导航栏颜色也要调整 */
[data-theme="light"] .header {
  background: rgba(255, 255, 255, 0.8);
}
```

#### 步骤 2 — 在 Header.astro 添加切换按钮和 JS

1. 在 `<nav>` 标签后面添加一个切换按钮：

```html
<button id="themeToggle" class="theme-toggle" aria-label="切换主题">
  <!-- 用文字或 emoji 表示，方便 -->
  <span id="themeIcon">🌙</span>
</button>
```

2. 在底部的 `<script>` 中添加切换主题的 JS 逻辑：

```javascript
// 主题切换逻辑
const themeToggle = document.getElementById('themeToggle');
const themeIcon = document.getElementById('themeIcon');

// 读取 localStorage 中的主题设置，如果没有就用 'dark'
const savedTheme = localStorage.getItem('theme') || 'dark';
document.documentElement.setAttribute('data-theme', savedTheme);
themeIcon.textContent = savedTheme === 'dark' ? '🌙' : '☀️';

themeToggle.addEventListener('click', () => {
  const current = document.documentElement.getAttribute('data-theme');
  const next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('theme', next);
  themeIcon.textContent = next === 'dark' ? '🌙' : '☀️';
});
```

3. 在 global.css 底部添加主题切换按钮的样式：

```css
.theme-toggle {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 50%;
  width: 36px;
  height: 36px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.125rem;
  transition: all 0.2s;
  margin-left: auto;
}

.theme-toggle:hover {
  border-color: var(--primary);
  box-shadow: 0 0 12px rgba(168, 85, 247, 0.3);
}
```

> ⚠️ 注意：Header 是 flex 布局（`.header-inner`），按钮加在 nav 后面，需要把 `.header-inner` 里的 `.nav` 和按钮一起包在一个 div 里，或者用 `margin-left: auto` 把按钮推到最右边。

---

## 任务 2：回到顶部按钮

### 改动文件
1. `src/layouts/BaseLayout.astro`（添加组件引用）
2. 新建 `src/components/BackToTop.astro`

### 具体实现

新建 `src/components/BackToTop.astro`，内容如下：

```astro
<!-- 回到顶部按钮组件 -->
<button id="backToTop" class="back-to-top" aria-label="回到顶部">
  ↑
</button>

<style>
.back-to-top {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--gradient-primary);
  color: white;
  border: none;
  cursor: pointer;
  font-size: 1.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transform: translateY(20px);
  transition: all 0.3s ease;
  z-index: 999;
  box-shadow: 0 4px 15px rgba(168, 85, 247, 0.3);
}

.back-to-top.visible {
  opacity: 1;
  visibility: visible;
  transform: translateY(0);
}

.back-to-top:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(168, 85, 247, 0.5);
}
</style>

<script>
const btn = document.getElementById('backToTop');

window.addEventListener('scroll', () => {
  if (window.scrollY > 300) {
    btn.classList.add('visible');
  } else {
    btn.classList.remove('visible');
  }
});

btn.addEventListener('click', () => {
  window.scrollTo({ top: 0, behavior: 'smooth' });
});
</script>
```

然后在 `BaseLayout.astro` 的 `<body>` 内（`<Footer />` 后面）添加：

```astro
<BackToTop />
```

记得在 frontmatter（`---` 代码块内）导入：

```typescript
import BackToTop from '../components/BackToTop.astro';
```

---

## 任务 3：博客阅读进度条

### 改动文件
1. `src/pages/blog/[slug].astro`（博客详情页）

### 具体实现

在 `[slug].astro` 的 `<article>` 标签之前添加进度条 HTML，并在底部添加对应的 script 和 style：

在 `<BaseLayout>` 内的最顶部（`<article>` 之前）添加：

```html
<!-- 阅读进度条 -->
<div id="readingProgress" class="reading-progress"></div>
```

在文件底部（或 `<style>` 块内）添加样式：

```css
.reading-progress {
  position: fixed;
  top: 0;
  left: 0;
  height: 3px;
  background: var(--gradient-primary);
  z-index: 1000;
  width: 0%;
  transition: width 0.1s linear;
}
```

由于 `[slug].astro` 使用的是 Astro 的 scoped style（style 标签不加 `is:global` 不会污染全局），建议把进度条样式放到文件底部的 `<style is:global>` 里，或者直接放在 global.css 中。

在文件底部添加 script：

```html
<script>
window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const scrollPercent = (scrollTop / docHeight) * 100;
  const bar = document.getElementById('readingProgress');
  if (bar) {
    bar.style.width = scrollPercent + '%';
  }
});
</script>
```

---

## 任务 4：标签/分类页面

### 改动文件
1. 新建 `src/pages/tags/[tag].astro`
2. 新建 `src/pages/tags/index.astro`
3. 修改 `src/pages/blog/[slug].astro`（让标签可点击跳转）

### 具体实现

#### 步骤 1 — 标签总览页 `src/pages/tags/index.astro`

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

// 获取所有博客文章
const allPosts = await getCollection('blog');

// 收集所有标签并统计文章数
const tagMap = new Map<string, number>();
for (const post of allPosts) {
  if (post.data.draft) continue; // 过滤草稿
  for (const tag of post.data.tags) {
    tagMap.set(tag, (tagMap.get(tag) || 0) + 1);
  }
}

// 按文章数量排序
const sortedTags = [...tagMap.entries()].sort((a, b) => b[1] - a[1]);
---

<BaseLayout title="标签 - ZONE" currentPath="/WEB/tags/">
  <section class="section container">
    <h1 class="section-title">文章标签</h1>
    {sortedTags.length > 0 ? (
      <div class="tags-cloud">
        {sortedTags.map(([tag, count]) => (
          <a href={`/WEB/tags/${tag}/`} class="tag-item">
            {tag}
            <span class="tag-count">{count}</span>
          </a>
        ))}
      </div>
    ) : (
      <p class="empty-state">暂无标签</p>
    )}
  </section>
</BaseLayout>

<style>
.tags-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  padding: 20px 0;
}

.tag-item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 999px;
  color: var(--text);
  font-size: 0.9375rem;
  transition: all 0.2s;
}

.tag-item:hover {
  border-color: var(--primary);
  color: var(--primary);
  text-decoration: none;
  transform: translateY(-2px);
}

.tag-count {
  background: var(--bg-secondary);
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 0.75rem;
  color: var(--text-secondary);
}
</style>
```

#### 步骤 2 — 单标签过滤页 `src/pages/tags/[tag].astro`

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import BlogCard from '../../components/BlogCard.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const allPosts = await getCollection('blog');
  const tags = new Set<string>();
  for (const post of allPosts) {
    if (post.data.draft) continue;
    for (const tag of post.data.tags) {
      tags.add(tag);
    }
  }
  return [...tags].map(tag => ({
    params: { tag },
  }));
}

const { tag } = Astro.params;
const allPosts = await getCollection('blog');
const filteredPosts = allPosts
  .filter(post => !post.data.draft && post.data.tags.includes(tag!))
  .sort((a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime());
---

<BaseLayout title={`${tag} - 标签 - ZONE`} currentPath={`/WEB/tags/${tag}/`}>
  <section class="section container">
    <h1 class="section-title">
      标签：{tag}
      <span class="tag-count-badge">{filteredPosts.length} 篇文章</span>
    </h1>
    <a href="/WEB/tags/" class="back-link">← 所有标签</a>
    {filteredPosts.length > 0 ? (
      <div class="card-grid">
        {filteredPosts.map(post => (
          <BlogCard
            title={post.data.title}
            description={post.data.description}
            date={post.data.date}
            tags={post.data.tags}
            slug={post.slug}
          />
        ))}
      </div>
    ) : (
      <p class="empty-state">该标签下暂无文章</p>
    )}
  </section>
</BaseLayout>

<style>
.tag-count-badge {
  font-size: 0.875rem;
  color: var(--text-secondary);
  font-weight: 400;
  margin-left: 8px;
}
</style>
```

#### 步骤 3 — 修改 `[slug].astro` 中的标签为可点击链接

在 `[slug].astro` 的文章详情页，找到显示标签的地方（`{post.data.tags.join(' / ')}`），改为遍历输出可点击链接：

```astro
{post.data.tags.length > 0 && (
  <span> · 
    {post.data.tags.map((tag, i) => (
      <span>
        {i > 0 && ' / '}
        <a href={`/WEB/tags/${tag}/`} class="tag-link">{tag}</a>
      </span>
    ))}
  </span>
)}
```

添加样式：

```css
.tag-link {
  color: var(--primary);
}

.tag-link:hover {
  text-decoration: underline;
}
```

#### 步骤 4 — 更新 astro.config.mjs 的 sitemap filter

修改 `astro.config.mjs` 中的 sitemap filter，允许标签页生成 sitemap：

```javascript
// 目前 filter 是过滤 /tags/ 的，改成不过滤
// 删掉 filter 那行，或改成：
filter: (page) => !page.includes('/tags/'),
// 改成：
// （去掉 filter 或注释掉）
```

或者直接注释掉 filter 行。

#### 步骤 5 — 在导航栏添加"标签"入口

在 `Header.astro` 的 `navItems` 数组中添加一项：

```typescript
const navItems = [
  { href: `${basePath}/`, label: '首页' },
  { href: `${basePath}/blog/`, label: '博客' },
  { href: `${basePath}/tags/`, label: '标签' },   // ← 新增
  { href: `${basePath}/projects/`, label: '作品集' },
  { href: `${basePath}/about`, label: '关于我' },
];
```

---

## 任务 5：RSS 订阅

### 改动文件
1. 安装依赖
2. 新建 `src/pages/rss.xml.js`

### 具体实现

#### 步骤 1 — 在终端执行安装

```bash
npm install @astrojs/rss
```

#### 步骤 2 — 新建 `src/pages/rss.xml.js`

```javascript
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
```

#### 步骤 3 — 在 Footer 添加 RSS 订阅链接

在 `Footer.astro` 中添加 RSS 图标链接：

```html
<div class="footer-links">
  <a href="/WEB/rss.xml" target="_blank" rel="noopener noreferrer">RSS</a>
  <a href="mailto:zone@example.com">邮箱</a>
</div>
```

---

## 最终检查清单

| 任务 | 文件改动 | 完成？ |
|------|---------|-------|
| 暗色/亮色模式切换 | `global.css` + `Header.astro` | ☐ |
| 回到顶部按钮 | 新建 `BackToTop.astro` + `BaseLayout.astro` | ☐ |
| 阅读进度条 | `[slug].astro` | ☐ |
| 标签总览页 | 新建 `tags/index.astro` | ☐ |
| 单标签过滤页 | 新建 `tags/[tag].astro` | ☐ |
| 标签可点击 | `[slug].astro` | ☐ |
| 导航栏加"标签"入口 | `Header.astro` | ☐ |
| RSS 订阅 | `npm install` + 新建 `rss.xml.js` | ☐ |
| Footer 加 RSS 链接 | `Footer.astro` | ☐ |

---

## 测试方法

完成所有修改后，在终端运行：

```bash
npm run dev
```

浏览器访问 `http://localhost:4321/WEB/` 查看效果。

确认没问题后运行构建：

```bash
npm run build
```

构建成功后推送到 GitHub：

```bash
git add .
git commit -m "第二阶段改进：主题切换、回到顶部、阅读进度条、标签页、RSS"
git push
```
