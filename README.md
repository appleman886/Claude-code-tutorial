# Claude Code 安装教程网站

这是一个帮助用户安装和配置 Claude Code 的静态网站，专门配置了阿里云百炼的模型服务。

## 功能特性

- 📱 **响应式设计** - 支持桌面、平板和移动设备
- 🎨 **现代化UI** - 美观的渐变色和动画效果
- 📖 **详细教程** - 分步骤指导安装和配置
- ⌨️ **快捷键支持** - 支持键盘快捷键导航
- 📋 **一键复制** - 点击代码块即可复制命令
- 🎯 **进度跟踪** - 清晰的安装进度指示

## 网站结构

```
claude-code-tutorial/
├── index.html          # 主页面
├── css/
│   └── styles.css      # 样式文件
├── js/
│   └── script.js       # 交互脚本
└── README.md           # 说明文档
```

## 部署方法

### 方法一：GitHub Pages（推荐）

1. **创建 GitHub 仓库**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/appleman886/claude-code-tutorial.git
   git push -u origin main
   ```

2. **启用 GitHub Pages**
   - 进入仓库的 Settings > Pages
   - 在 "Build and deployment" 中选择 Source 为 "Deploy from a branch"
   - 选择分支为 `main` 和文件夹为 `/ (root)`
   - 点击 Save

3. **访问网站**
   - 等待几分钟，访问 `https://appleman886.github.io/claude-code-tutorial/`

### 方法二：Netlify

1. 访问 [Netlify](https://www.netlify.com/)
2. 拖拽项目文件夹到 Netlify Dashboard
3. 网站会自动部署

### 方法三：Vercel

1. 安装 Vercel CLI：
   ```bash
   npm install -g vercel
   ```

2. 在项目目录运行：
   ```bash
   vercel
   ```

### 方法四：本地服务器

1. 使用 Python：
   ```bash
   python -m http.server 8000
   ```

2. 或使用 Node.js：
   ```bash
   npx serve
   ```

3. 访问 `http://localhost:8000`

## 教程内容

网站包含以下教程部分：

1. **首页** - 网站介绍和快速开始指南
2. **Node.js 安装** - Node.js 运行环境的安装步骤
3. **Git 安装** - 版本控制工具的安装步骤
4. **Claude Code 安装** - Claude Code CLI 工具的安装
5. **阿里云百炼配置** - 阿里云百炼 API 的配置方法

## 快捷键

- `Ctrl/Cmd + 1-5` - 快速导航到各个教程部分
- `←` `→` - 左右箭头键在教程页面间切换
- 点击代码块 - 自动复制命令到剪贴板

## 自定义配置

### 修改颜色主题

在 `css/styles.css` 中修改 CSS 变量：

```css
:root {
    --primary-color: #6366f1;    /* 主色调 */
    --secondary-color: #8b5cf6;  /* 次要色调 */
    --background: #0f172a;       /* 背景色 */
    /* ... 其他颜色变量 */
}
```

### 修改内容

直接编辑 `index.html` 中的教程内容。

## 浏览器兼容性

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 技术栈

- HTML5
- CSS3（包含 Flexbox、Grid、渐变、动画）
- Vanilla JavaScript（无依赖）

## 许可证

MIT License

## 贡献

欢迎提交问题和改进建议！

## 联系方式

- GitHub: https://github.com/appleman886
- 如有问题请在 GitHub 上提交 Issue

---

**注意**: 本教程仅供学习和参考使用，请确保在使用阿里云百炼 API 时遵守相关服务条款。