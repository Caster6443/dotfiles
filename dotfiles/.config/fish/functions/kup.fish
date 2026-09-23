function kup --description '按需启动 kind 学习集群，并等到节点 Ready'
    set -l cluster kind
    set -l nodes (docker ps -aq --filter "label=io.x-k8s.kind.cluster=$cluster" 2>/dev/null)

    if test (count $nodes) -eq 0
        echo "没找到 kind 集群（标签 io.x-k8s.kind.cluster=$cluster）的节点容器" >&2
        return 1
    end

    # 只启动那些还没在跑的节点
    set -l tostart
    for n in $nodes
        if test (docker inspect -f '{{.State.Running}}' $n) != true
            set -a tostart $n
        end
    end

    if test (count $tostart) -gt 0
        for n in $tostart
            echo "启动 "(docker inspect -f '{{.Name}}' $n | string replace -r '^/' '')
        end
        docker start $tostart >/dev/null
    else
        echo "三个节点容器都已在运行"
    end

    # 等节点全部 Ready（首次恢复实测约 10 秒）
    set -l want (count $nodes)
    set -l ready 0
    for i in (seq 1 60)
        set ready (kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ')
        if test "$ready" -ge "$want"
            echo "集群就绪（$ready/$want 节点 Ready）"
            kubectl get nodes
            return 0
        end
        sleep 2
    end

    echo "等待超时：只有 $ready/$want 节点 Ready" >&2
    kubectl get nodes
    echo "排查：kubectl get nodes; kubectl get pods -A; docker ps --filter label=io.x-k8s.kind.cluster=$cluster" >&2
    return 1
end
