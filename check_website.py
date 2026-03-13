#!/usr/bin/env python3
import urllib.request
import urllib.error
import time
from urllib.parse import urljoin

def check_website_status():
    """检查网站状态"""
    base_url = "https://appleman886.github.io/Claude-code-tutorial/"

    print("正在检查 GitHub Pages 网站...")
    print(f"URL: {base_url}")
    print("-" * 50)

    # 检查主页面
    try:
        request = urllib.request.Request(base_url)
        request.add_header('User-Agent', 'Mozilla/5.0')

        with urllib.request.urlopen(request, timeout=10) as response:
            status_code = response.getcode()
            headers = dict(response.headers)
            content = response.read().decode('utf-8')

            print(f"状态码: {status_code}")
            print(f"响应头: {headers}")

            if status_code == 200:
                print("✅ GitHub Pages 网站可访问")

                # 检查内容
                content_length = len(content)
                print(f"内容长度: {content_length} 字符")

                # 检查是否包含预期的标题
                if "Claude Code" in content:
                    print("✅ 页面包含正确的标题内容")
                else:
                    print("⚠️ 页面可能没有预期的内容")

            else:
                print(f"❌ 网站返回错误: {status_code}")

    except urllib.error.HTTPError as e:
        print(f"❌ HTTP 错误: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"❌ URL 错误: {e.reason}")
    except Exception as e:
        print(f"❌ 连接失败: {e}")

    print("-" * 50)

    # 检查具体资源
    resources = [
        "css/styles.css",
        "js/script.js"
    ]

    print("正在检查资源文件...")
    for resource in resources:
        full_url = urljoin(base_url, resource)
        try:
            request = urllib.request.Request(full_url)
            request.add_header('User-Agent', 'Mozilla/5.0')

            with urllib.request.urlopen(request, timeout=5) as response:
                print(f"{resource}: {response.getcode()}")
        except Exception as e:
            print(f"{resource}: 无法访问 - {e}")

if __name__ == "__main__":
    check_website_status()