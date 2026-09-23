function kdown --description '优雅停止 kind 学习集群（三节点并行停，约 90 秒）'
    set -l cluster kind
    set -l nodes (docker ps -q --filter "label=io.x-k8s.kind.cluster=$cluster" 2>/dev/null)

    if test (count $nodes) -eq 0
        echo "kind 集群本来就没在运行"
        return 0
    end

    # 每个节点等多久才强杀；kind 节点内部 systemd 停机实测约 90 秒。
    # 想更快可设 set -Ux KIND_STOP_TIMEOUT 10（10 秒后强杀，etcd 靠 WAL 一般也能恢复）。
    set -l timeout 120
    if set -q KIND_STOP_TIMEOUT
        set timeout $KIND_STOP_TIMEOUT
    end

    echo "并行停止 "(count $nodes)" 个节点（每个最多等 "$timeout"s）"
    for n in $nodes
        echo "  → "(docker inspect -f '{{.Name}}' $n | string replace -r '^/' '')
        docker stop -t $timeout $n >/dev/null 2>&1 &
    end
    wait

    echo "已停止。集群数据（etcd、已建对象）都在节点容器里，kup 即可原样恢复。"
end
