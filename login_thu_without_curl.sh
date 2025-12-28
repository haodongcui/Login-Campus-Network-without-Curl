#!/bin/bash
# -------------------------------- #
# 日期: 2025-12-29 (适用于当时的清华校园网认证页面, 未来可能会失效)
# 功能: 服务器在没有 curl 的情况下, 登录清华校园网
# -------------------------------- #

# 提示信息
echo "在 cursor / vscode 设置端口转发为"
echo "--------------------------------"
echo "端口: 8888"
echo "转发端口: localhost:8888"
echo "--------------------------------"
echo "访问清华认证页面: http://127.0.0.1:8888/index_171.html"
echo "进去认证页面后, 输入账密登录就可以了"
echo "--------------------------------"
echo "登录完成之后, 可以关闭终端了"
echo "赶紧去下载 curl 吧 !"

# 端口中转 python 脚本
cat << 'EOF' > ./tunnel.py
import socket
import threading

def pipe(src, dst):
    while True:
        try:
            data = src.recv(4096)
            if not data:
                break
            dst.sendall(data)
        except:
            break
    src.close()
    dst.close()

def main():
    local_port = 8888
    remote_host = "101.6.4.100"  # 清华网关 IP
    remote_port = 80
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", local_port))
    server.listen(5)
    print(f"[*] 服务器 {local_port} 端口已启动，正在中转到 {remote_host}:{remote_port}")
    
    try:
        while True:
            client, addr = server.accept()
            print(f"[*] 收到来自 {addr} 的连接")
            remote = socket.create_connection((remote_host, remote_port))
            threading.Thread(target=pipe, args=(client, remote)).start()
            threading.Thread(target=pipe, args=(remote, client)).start()
    except KeyboardInterrupt:
        print("\n[*] 停止中转")
        server.close()

if __name__ == "__main__":
    main()
EOF

# 确保脚本退出时删除临时文件
trap "rm -f ./tunnel.py; exit" INT TERM EXIT

# 启用端口转发
python ./tunnel.py