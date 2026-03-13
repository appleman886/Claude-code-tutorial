#!/usr/bin/env python3
import urllib.request
import urllib.error
import json
import datetime
import os

def monitor_website():
    """监控网站状态"""
    base_url = "https://appleman886.github.io/Claude-code-tutorial/"
    log_file = os.path.join(os.path.dirname(__file__), "..", "website_status.log")

    def log_message(message):
        """记录日志消息"""
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {message}\n"

        print(log_entry.strip())

        # 写入日志文件
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(log_entry)

    def check_accessibility(url):
        """检查网站可访问性"""
        try:
            request = urllib.request.Request(url)
            request.add_header('User-Agent', 'Mozilla/5.0 (compatible; Website Monitor/1.0)')

            with urllib.request.urlopen(request, timeout=10) as response:
                status_code = response.getcode()
                content = response.read().decode('utf-8', errors='ignore')

                return {
                    'status': 'up',
                    'status_code': status_code,
                    'size': len(content),
                    'has_content': 'Claude Code' in content,
                    'timestamp': datetime.datetime.now().isoformat()
                }
        except urllib.error.HTTPError as e:
            return {
                'status': 'error',
                'status_code': e.code,
                'message': str(e.reason),
                'timestamp': datetime.datetime.now().isoformat()
            }
        except urllib.error.URLError as e:
            return {
                'status': 'down',
                'message': str(e.reason),
                'timestamp': datetime.datetime.now().isoformat()
            }
        except Exception as e:
            return {
                'status': 'error',
                'message': str(e),
                'timestamp': datetime.datetime.now().isoformat()
            }

    log_message("=== 网站监控开始 ===")

    # 检查主网站
    result = check_accessibility(base_url)

    if result['status'] == 'up':
        log_message(f"✅ 网站正常 - 状态码: {result['status_code']}")
        log_message(f"   内容大小: {result['size']} 字符")
        log_message(f"   内容验证: {'✅ 通过' if result['has_content'] else '❌ 失败'}")

        # 检查关键资源
        resources = ["css/styles.css", "js/script.js"]
        for resource in resources:
            resource_url = base_url.rstrip('/') + '/' + resource
            resource_result = check_accessibility(resource_url)
            log_message(f"   {resource}: {'✅' if resource_result['status'] == 'up' else '❌'} ({resource_result['status_code'] if 'status_code' in resource_result else 'N/A'})")
    else:
        log_message(f"❌ 网站异常 - {result['status']}: {result.get('message', 'Unknown error')}")

    log_message("=== 监控完成 ===\n")

    # 返回结果供其他程序使用
    return result

if __name__ == "__main__":
    result = monitor_website()

    # 如果网站不可用，返回非零退出码
    if result['status'] != 'up':
        exit(1)