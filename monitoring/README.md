# 网站监控工具

## 📋 概述

这个目录包含了网站监控和维护工具，用于确保 Claude Code 教程网站正常运行。

## 🛠️ 工具列表

### website_monitor.py
**功能**: 监控网站可访问性和关键资源

**使用方法**:
```bash
# 直接运行
python website_monitor.py

# 或者进入监控目录运行
cd monitoring
python website_monitor.py
```

**输出示例**:
```
[2026-03-13 15:30:00] === 网站监控开始 ===
[2026-03-13 15:30:01] ✅ 网站正常 - 状态码: 200
[2026-03-13 15:30:01]    内容大小: 37247 字符
[2026-03-13 15:30:01]    内容验证: ✅ 通过
[2026-03-13 15:30:01]    css/styles.css: ✅ (200)
[2026-03-13 15:30:01]    js/script.js: ✅ (200)
[2026-03-13 15:30:01] === 监控完成 ===
```

**返回码**:
- 0: 网站正常
- 1: 网站不可用

### website_status.log
**功能**: 记录监控日志

**位置**: 项目根目录的 `website_status.log`

## 🔄 定期监控

### Windows 任务计划
1. 打开"任务计划程序"
2. 创建基本任务
3. 触发器: 每天/每周
4. 操作: 启动程序 `python C:\path\to\website_monitor.py`

### Linux Crontab
```bash
# 每小时运行一次
0 * * * * /usr/bin/python3 /path/to/website_monitor.py >> /path/to/monitor.log 2>&1

# 每天 9 点运行
0 9 * * * /usr/bin/python3 /path/to/website_monitor.py
```

### GitHub Actions (可选)
创建 `.github/workflows/monitor.yml`:
```yaml
name: Website Monitor
on:
  schedule:
    - cron: '0 9 * * *'  # 每天 9 点 UTC

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Run Monitor
        run: |
          cd monitoring
          python website_monitor.py
```

## 🔍 监控指标

### 检查项目
- [ ] 主网站响应状态 (200)
- [ ] 内容大小合理 (> 10KB)
- [ ] 包含预期的内容 ("Claude Code")
- [ ] CSS 文件可访问
- [ ] JavaScript 文件可访问

### 告警阈值
- **响应时间**: > 10秒
- **内容大小**: < 10KB
- **错误率**: > 5% (连续3次失败)

## 📊 数据分析

使用 `website_status.log` 可以进行:
- 可用性统计
- 响应时间分析
- 错误模式识别
- 趋势报告

## 🚨 故障处理

如果监控显示网站不可用:
1. 检查网络连接
2. 使用代理工具测试
3. 查看 GitHub Actions 日志
4. 检查仓库配置
5. 联系 GitHub 支持

---

**创建时间**: 2026-03-13
**维护**: appleman886