#!/bin/bash
# SearXNG 验证脚本

BASE_URL="http://localhost:8873"

echo "=== SearXNG 验证脚本 ==="
echo ""

# 1. 健康检查
echo "1. 健康检查..."
HEALTH=$(curl -s "$BASE_URL/healthz")
if [ "$HEALTH" = "OK" ]; then
    echo "   ✓ 健康检查通过：$HEALTH"
else
    echo "   ✗ 健康检查失败：$HEALTH"
    exit 1
fi

# 2. 首页访问
echo "2. 首页访问..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✓ 首页访问通过：HTTP $HTTP_CODE"
else
    echo "   ✗ 首页访问失败：HTTP $HTTP_CODE"
    exit 1
fi

# 3. 搜索测试
echo "3. 搜索测试..."
RESULT=$(curl -s -X POST "$BASE_URL/search" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "q=github&category_general=1")

if echo "$RESULT" | grep -q "github.com"; then
    echo "   ✓ 搜索测试通过：找到 github.com 相关结果"
else
    echo "   ✗ 搜索测试失败：未找到预期结果"
    exit 1
fi

# 4. 引擎状态
echo "4. 引擎状态..."
ENGINE_COUNT=$(echo "$RESULT" | grep -oE 'engine_[a-z_]+' | sort -u | wc -l)
echo "   ✓ 参与搜索的引擎数：$ENGINE_COUNT"

echo ""
echo "=== 所有验证通过 ==="
echo "访问地址：$BASE_URL"
