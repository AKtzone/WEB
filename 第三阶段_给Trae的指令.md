# 第三阶段改进 — 给 Trae 的执行指令

> 项目路径：D:\Project\WEB
> 优先级按推荐顺序排列

---

## 任务 1：Giscus 评论区

### 前置准备 — 你需要在 GitHub 上操作

1. 打开 https://github.com/AKtzone/WEB
2. 点击顶部的 **Settings** → 勾选 **Discussions** → Save
3. 打开 https://github.com/apps/giscus 安装 Giscus App，授权给 `AKtzone/WEB` 仓库
4. 打开 https://giscus.app/zh-CN 配置：
   - 仓库：`AKtzone/WEB`
   - 页面与 Discussion 映射：选择 `Discussion title contains page URL`
   - Discussion 分类：选择 `Announcements`（或新建一个叫 `Blog Comments` 的分类）
   - 主题：选择 `noborder_dark`（匹配暗色主题）
   - 复制下方生成的两段代码（`<script>` 和 `<div>`）

### 改动文件

1. `src/pages/blog/[slug].astro`

### 具体实现

在 `[slug].astro` 中的 `<article>` 结束之后、`<a href="/WEB/blog/">` 返回链接之前，插入 Giscus 评论区组件：

```html
<!-- Giscus 评论区 -->
<div class="giscus-container">
  <h2 class="section-title">评论</h2>
  <div id="giscus-comments"></div>
</div>

<script>
  // Giscus 评论区脚本
  const script = document.createElement('script');
  script.src = 'https://giscus.app/client.js';
  script.setAttribute('data-repo', 'AKtzone/WEB');
  script.setAttribute('data-repo-id', 'R_kgDOSZd03A');
  script.setAttribute('data-category', 'Announcements');
  script.setAttribute('data-category-id', 'DIC_kwDOSZd03M4C8uP6');
  script.setAttribute('data-mapping', 'url');
  script.setAttribute('data-strict', '0');
  script.setAttribute('data-reactions-enabled', '1');
  script.setAttribute('data-emit-metadata', '0');
  script.setAttribute('data-input-position', 'bottom');
  script.setAttribute('data-theme', 'noborder_dark');
  script.setAttribute('data-lang', 'zh-CN');
  script.setAttribute('crossorigin', 'anonymous');
  script.async = true;
  document.getElementById('giscus-comments').appendChild(script);
</script>

<style>
.giscus-container {
  margin-top: 48px;
  padding-top: 32px;
  border-top: 1px solid var(--border);
}
</style>
```

> ✅ Giscus 已配置完成！仓库 `AKtzone/WEB` 的 Discussions 已启用，Giscus App 已授权，以上代码可直接使用。

---

## 任务 2：自定义 404 页面

### 改动文件

1. 新建 `src/pages/404.astro`

### 具体实现

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
---

<BaseLayout title="页面未找到 - ZONE" currentPath="/WEB/404">
  <section class="not-found">
    <div class="not-found-code">404</div>
    <h1 class="gradient-text">页面未找到</h1>
    <p>你访问的页面不存在，可能已被移除或链接有误。</p>
    <a href="/WEB/" class="btn btn-primary">返回首页</a>
  </section>
</BaseLayout>

<style>
.not-found {
  text-align: center;
  padding: 100px 20px;
  max-width: 600px;
  margin: 0 auto;
}

.not-found-code {
  font-size: 6rem;
  font-weight: 800;
  background: var(--gradient-text);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1;
  margin-bottom: 16px;
}

.not-found h1 {
  font-size: 1.75rem;
  margin-bottom: 12px;
}

.not-found p {
  color: var(--text-secondary);
  font-size: 1.125rem;
  margin-bottom: 32px;
}

.not-found .btn {
  display: inline-flex;
}
</style>
```

---

## 任务 3：文章目录（TOC）

### 改动文件

1. `src/pages/blog/[slug].astro`

### 具体实现

在 `[slug].astro` 的 `<article>` 开始标签之后、`<header>` 之前，添加 TOC 容器：

```astro
<!-- 文章目录 -->
<details class="toc" open>
  <summary class="toc-title">📑 目录</summary>
  <nav id="tableOfContents" class="toc-list"></nav>
</details>
```

在文件底部的 `<script>` 中（阅读进度条后面）添加 TOC 生成逻辑：

```javascript
// 自动生成文章目录
const toc = document.getElementById('tableOfContents');
if (toc) {
  const headings = document.querySelectorAll('.article-content h2, .article-content h3');
  const list = document.createElement('ul');
  headings.forEach((h, index) => {
    // 如果没有 id，自动生成一个
    if (!h.id) {
      h.id = 'heading-' + index;
    }
    const li = document.createElement('li');
    li.className = h.tagName === 'H3' ? 'toc-h3' : 'toc-h2';
    const a = document.createElement('a');
    a.href = '#' + h.id;
    a.textContent = h.textContent;
    li.appendChild(a);
    list.appendChild(li);
  });
  toc.appendChild(list);
}
```

添加 TOC 样式：

```css
/* 目录样式 */
.toc {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 20px;
  margin-bottom: 32px;
}

.toc-title {
  font-weight: 600;
  cursor: pointer;
  color: var(--primary);
  margin-bottom: 8px;
}

.toc-list {
  padding: 0;
}

.toc-list ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.toc-list li {
  padding: 4px 0;
}

.toc-list li.toc-h3 {
  padding-left: 20px;
}

.toc-list a {
  color: var(--text-secondary);
  font-size: 0.9375rem;
  transition: color 0.2s;
}

.toc-list a:hover {
  color: var(--primary);
  text-decoration: none;
}
```

---

## 任务 4：阅读时间估算

### 改动文件

1. `src/components/BlogCard.astro`（卡片显示阅读时间）
2. `src/pages/blog/[slug].astro`（详情页显示阅读时间）

### 具体实现

创建一个工具函数来计算阅读时间。在 `src/pages/blog/[slug].astro` 的 frontmatter 中添加：

```typescript
// 估算阅读时间（中文每分钟约300字）
function estimateReadingTime(content: string): number {
  const chineseChars = content.match(/[\u4e00-\u9fff]/g) || [];
  const wordCount = chineseChars.length;
  const minutes = Math.max(1, Math.ceil(wordCount / 300));
  return minutes;
}

// 获取文章正文内容用于计算阅读时间
// 注意：post.body 在 Astro content collection 中可用
const readingTime = estimateReadingTime(post.body);
```

在详情页的 `article-meta` 中显示：

```astro
<p class="article-meta">
  {formattedDate}
  <span> · ⏱ {readingTime} 分钟阅读</span>
  ...
```

对 BlogCard 组件也做同样的处理。在 `BlogCard.astro` 中添加阅读时间：

```astro
<p class="card-meta">
  {formattedDate}
  {tags.length > 0 && (
    <span> · ⏱ {readingTime} 分钟阅读</span>
  )}
</p>
```

> ⚠️ 注意：在 BlogCard 中获取 body 需要通过 Astro.glob 或 getCollection 传入。最简单的方法是在 BlogCard 的 props 中新增一个 `readingTime` 参数，然后在页面层计算并传入。

---

## 任务 5：代码块复制按钮

### 改动文件

1. `src/pages/blog/[slug].astro`

### 具体实现

在 `[slug].astro` 的文件底部 script 中添加代码块复制功能：

```html
<script>
// ... 已有的阅读进度条和 TOC 代码 ...

// 代码块复制按钮
document.querySelectorAll('.article-content pre').forEach((pre, index) => {
  // 创建复制按钮
  const button = document.createElement('button');
  button.className = 'copy-btn';
  button.textContent = '📋 复制';
  button.setAttribute('aria-label', '复制代码');
  
  // pre 设为相对定位
  pre.style.position = 'relative';
  
  // 按钮插入到 pre 的右上角
  pre.appendChild(button);
  
  button.addEventListener('click', async () => {
    const code = pre.querySelector('code');
    if (code) {
      try {
        await navigator.clipboard.writeText(code.textContent || '');
        button.textContent = '✅ 已复制';
        button.classList.add('copied');
        setTimeout(() => {
          button.textContent = '📋 复制';
          button.classList.remove('copied');
        }, 2000);
      } catch {
        button.textContent = '❌ 复制失败';
      }
    }
  });
});
</script>

<style>
.copy-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e2e8f0;
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.2s;
  opacity: 0;
}

.article-content pre:hover .copy-btn {
  opacity: 1;
}

.copy-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.copy-btn.copied {
  background: rgba(34, 197, 94, 0.3);
  border-color: #22c55e;
}
</style>
```

---

## 最终检查清单

| 任务 | 文件改动 | 完成？ |
|------|---------|-------|
| Giscus 评论区 | `blog/[slug].astro` | ☐ |
| 自定义 404 页面 | 新建 `pages/404.astro` | ☐ |
| 文章目录 TOC | `blog/[slug].astro` | ☐ |
| 阅读时间估算 | `BlogCard.astro` + `[slug].astro` | ☐ |
| 代码块复制按钮 | `blog/[slug].astro` | ☐ |

> ⚠️ 注意：做完后运行 `npm run dev` 测试，然后 `npm run build` 构建，最后 `git add . && git commit -m "第三阶段改进" && git push` 部署。
