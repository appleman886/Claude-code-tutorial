# Netlify 自动部署配置

## 配置步骤

### 方法一：通过 Netlify 网站配置（推荐）

1. **访问 Netlify**
   - 打开 https://app.netlify.com/
   - 登录你的 Netlify 账号（可以使用 GitHub 账号登录）

2. **添加新站点**
   - 点击 "Add new site" → "Import an existing project"
   - 选择 "GitHub"
   - 授权 Netlify 访问你的 GitHub 账号

3. **选择仓库**
   - 在仓库列表中找到 `appleman886/Claude-code-tutorial`
   - 点击选择该仓库

4. **配置构建设置**
   - **Branch to deploy**: `main`
   - **Build command**: （留空，或填写 `echo 'Static site'`）
   - **Publish directory**: （留空，或填写 `.`）
   - 勾选 "Already configured with netlify.toml"（如果检测到）

5. **点击 "Deploy site"**
   - Netlify 会自动开始首次部署
   - 部署完成后会生成一个随机域名，如 `xxx.netlify.app`

6. **配置自定义域名（可选）**
   - 在 Site settings → Domain management 中添加自定义域名

### 方法二：通过 Netlify CLI 配置

1. **安装 Netlify CLI**
   ```bash
   npm install -g netlify-cli
   ```

2. **登录 Netlify**
   ```bash
   netlify login
   ```

3. **初始化项目**
   ```bash
   netlify init
   ```

4. **手动部署**
   ```bash
   netlify deploy --prod
   ```

## 自动部署说明

配置完成后，每次向 `main` 分支推送代码时：
- Netlify 会自动检测到代码变更
- 自动触发构建和部署
- 部署完成后，网站会自动更新
- 可以在 Netlify Dashboard 查看部署状态和历史

## 部署状态

- **自动触发**: ✅ 代码推送到 main 分支自动部署
- **构建命令**: 不需要（静态网站）
- **发布目录**: 项目根目录

## 访问地址

- **Netlify 默认域名**: https://claude-code-tutorial.netlify.app
- **部署日志**: https://app.netlify.com/sites/claude-code-tutorial/deploys

## 常见问题

### Q: 部署失败怎么办？
A: 在 Netlify Dashboard 查看部署日志，检查是否有错误信息。

### Q: 如何清除 CDN 缓存？
A: 在 Netlify Dashboard → Deploys → 点击最新部署 → 点击 "Clear cache and retry deploy"。

### Q: 如何回滚到之前的版本？
A: 在 Deploys 页面找到之前的成功部署，点击 "Publish deploy" 即可回滚。

---

**最后更新**: 2026-03-14
**状态**: ✅ 已配置自动部署
