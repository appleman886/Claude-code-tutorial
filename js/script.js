// 页面导航功能
function navigateTo(sectionId) {
    // 保存当前滚动位置
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    // 获取所有section和nav-link
    const sections = document.querySelectorAll('.section');
    const navLinks = document.querySelectorAll('.nav-link');

    // 移除所有active类
    sections.forEach(section => section.classList.remove('active'));
    navLinks.forEach(link => link.classList.remove('active'));

    // 添加active类到目标section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');

        // 添加active类到对应的nav-link
        const targetLink = document.querySelector(`.nav-link[href="#${sectionId}"]`);
        if (targetLink) {
            targetLink.classList.add('active');
        }
    }

    // 恢复滚动位置
    window.scrollTo({
        top: scrollTop,
        behavior: 'auto'
    });
}

// 导航链接点击事件
document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        const sectionId = this.getAttribute('href').substring(1);
        navigateTo(sectionId);
    });
});

// 初始化
document.addEventListener('DOMContentLoaded', function() {
    // 默认显示首页
    navigateTo('home');
});

// 添加复制功能
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        showToast('已复制到剪贴板！');
    }).catch(err => {
        console.error('复制失败:', err);
        showToast('复制失败，请手动复制');
    });
}

// 显示提示信息
function showToast(message) {
    // 创建toast元素
    const toast = document.createElement('div');
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
        color: white;
        padding: 15px 25px;
        border-radius: 10px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;

    // 添加动画
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);

    document.body.appendChild(toast);

    // 3秒后移除
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(toast);
        }, 300);
    }, 3000);
}

// 代码块点击复制功能
document.querySelectorAll('.code-block').forEach(codeBlock => {
    codeBlock.style.cursor = 'pointer';
    codeBlock.title = '点击复制代码';

    codeBlock.addEventListener('click', function() {
        const code = this.querySelector('code').textContent;
        copyToClipboard(code);
    });
});

// 键盘快捷键
document.addEventListener('keydown', function(e) {
    // Ctrl/Cmd + 数字键快速导航
    if (e.ctrlKey || e.metaKey) {
        const sections = ['home', 'nodejs', 'git', 'claude-code', 'zhipu-api'];
        const num = parseInt(e.key);

        if (num >= 1 && num <= sections.length) {
            e.preventDefault();
            navigateTo(sections[num - 1]);
        }
    }

    // 左右箭头键切换页面
    const sections = ['home', 'nodejs', 'git', 'claude-code', 'zhipu-api'];
    const activeSection = document.querySelector('.section.active');
    if (activeSection) {
        const currentIndex = sections.indexOf(activeSection.id);

        if (e.key === 'ArrowLeft' && currentIndex > 0) {
            e.preventDefault();
            navigateTo(sections[currentIndex - 1]);
        } else if (e.key === 'ArrowRight' && currentIndex < sections.length - 1) {
            e.preventDefault();
            navigateTo(sections[currentIndex + 1]);
        }
    }
});

// 进度指示器（可选功能）
function updateProgress() {
    const sections = document.querySelectorAll('.section');
    const activeSection = document.querySelector('.section.active');
    const total = sections.length;
    const current = Array.from(sections).indexOf(activeSection) + 1;
    const percentage = (current / total) * 100;

    // 可以在这里添加进度条UI
    console.log(`进度: ${current}/${total} (${percentage}%)`);
}

// 每次切换页面时更新进度
const originalNavigateTo = navigateTo;
navigateTo = function(sectionId) {
    originalNavigateTo(sectionId);
    updateProgress();
};

// 面包屑导航
function createBreadcrumbs() {
    const sections = [
        { id: 'home', name: '首页' },
        { id: 'nodejs', name: 'Node.js' },
        { id: 'git', name: 'Git' },
        { id: 'claude-code', name: 'Claude Code' },
        { id: 'zhipu-api', name: '智谱API' }
    ];

    const activeSection = document.querySelector('.section.active');
    if (!activeSection) return;

    const currentIndex = sections.findIndex(s => s.id === activeSection.id);
    if (currentIndex === -1) return;

    const breadcrumbs = document.createElement('div');
    breadcrumbs.className = 'breadcrumbs';
    breadcrumbs.innerHTML = sections.slice(0, currentIndex + 1)
        .map((s, i) => `<span class="breadcrumb ${i === currentIndex ? 'active' : ''}" data-section="${s.id}">${s.name}</span>`)
        .join(' <span class="breadcrumb-separator">→</span> ');

    // 插入到section标题之前
    const sectionTitle = activeSection.querySelector('.section-title');
    if (sectionTitle && !activeSection.querySelector('.breadcrumbs')) {
        sectionTitle.parentNode.insertBefore(breadcrumbs, sectionTitle);
    }
}

// 面包屑点击事件
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('breadcrumb') && !e.target.classList.contains('active')) {
        const sectionId = e.target.getAttribute('data-section');
        navigateTo(sectionId);
    }
});

// 更新面包屑样式
const style = document.createElement('style');
style.textContent = `
    .breadcrumbs {
        margin-bottom: 20px;
        font-size: 0.9rem;
        color: var(--text-muted);
    }

    .breadcrumb {
        cursor: pointer;
        transition: color 0.3s ease;
    }

    .breadcrumb:hover {
        color: var(--primary-color);
    }

    .breadcrumb.active {
        color: var(--primary-color);
        font-weight: 600;
    }

    .breadcrumb-separator {
        margin: 0 10px;
        color: var(--border-color);
    }
`;
document.head.appendChild(style);
// 操作系统选择功能
function selectOS(osName) {
    // 更新按钮状态
    const osButtons = document.querySelectorAll('.os-btn');
    osButtons.forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.os === osName) {
            btn.classList.add('active');
        }
    });

    // 更新显示的系统名称
    const osDisplays = document.querySelectorAll('.os-display');
    const osNames = {
        'windows': 'Windows',
        'macos': 'macOS',
        'linux': 'Linux'
    };
    osDisplays.forEach(display => {
        display.textContent = osNames[osName];
    });

    // 更新各部分的内容显示
    const allOsContent = document.querySelectorAll('.os-content');
    allOsContent.forEach(content => {
        content.classList.remove('active');
    });

    const selectedContents = document.querySelectorAll(`.os-${osName}`);
    selectedContents.forEach(content => {
        content.classList.add('active');
    });

    // 更新小贴士中的提示
    const tipBoxes = document.querySelectorAll('.tip-box p');
    tipBoxes.forEach(tip => {
        tip.innerHTML = tip.innerHTML.replace(/<span class="os-[^"]*">.*?<\/span>/g, '');
        const span = document.createElement('span');
        if (osName === 'windows') {
            span.className = 'os-windows';
            span.textContent = '请以管理员身份运行命令提示符。';
        } else {
            span.className = `os-${osName}`;
            span.textContent = '请使用 sudo 命令或在命令前加 sudo。';
        }
        tip.appendChild(span);
    });
}

// 初始化时默认选择 Windows
document.addEventListener('DOMContentLoaded', function() {
    selectOS('windows');
});
