# x402 + Cobo CAW Agent 自主支付闭环 Demo

> Repo: https://github.com/chxii/agent-commerce-demo
> 目标：展示 Agent 在明确授权、预算控制、可审计记录下完成自动交易

---

## 1. 架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Agent (off-chain)                                │
│  ┌─────────────┐   ┌──────────────┐   ┌─────────────────────────────┐   │
│  │  Audit Log  │   │  Agent Core  │   │   BudgetGuard (caw_client)   │   │
│  │  ─────────  │   │  ──────────   │   │   ───────────────────────    │   │
│  │  action     │◄──│  1. 请求API   │   │   budget_remaining           │   │
│  │  tx_hash    │   │  2. 检测402   │   │   allowed_addresses          │   │
│  │  status    │   │  3. 发支付    │◄──│   time_window                │   │
│  │  timestamp │   │  4. 重试拿数据 │   │   check() → boolean          │   │
│  └─────────────┘   └──────────────┘   └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
         │                   ▲                │                    │
         │                   │                │                    │
         ▼                   │                ▼                    ▼
┌──────────────────┐  ┌────────────┐  ┌──────────────────────────────────────┐
│  x402 Server      │  │  402 resp  │  │       Base Sepolia                   │
│  (Flask / API)    │  │            │  │  ┌────────────────────────────┐      │
│                   │  │            │  │  │  USDC Contract             │      │
│  GET /analyze ───►│──│            │  │  │  transfer(to, amount)      │      │
│                   │  │            │  │  └────────────────────────────┘      │
│  ◄── data (200)  │  │            │  │            │                         │
│                   │  │            │  │            ▼                         │
│                   │  │            │  │  ┌────────────────────────────┐      │
│                   │  │            │  │  │  tx_hash → on-chain       │      │
│                   │  │            │  │  │  proof record             │      │
│                   │  │            │  │  └────────────────────────────┘      │
│  ┌──────────────┐ │  │            │  │                                   │
│  │ Verify proof │◄─┼──┤            │  │  ◄── wait_for_receipt              │
│  │ (tx_hash)   │ │  │            │  │                                   │
│  │ Replay check │ │  │            │  │                                   │
│  └──────────────┘ │  │            │  │                                   │
└───────────────────┼──┴────────────┘  └───────────────────────────────────┘
                     │                 ▲
                     │                 │
                     │                 │
              X-Payment-Proof: 0x...  │
                     │                 │
                     │                 │
         ┌───────────┘                 │
         │                             │
         ▼                             │
┌──────────────────┐                  │
│  Cobo CAW SDK    │◄─────────────────┘
│  (Mock / Real)    │   transfer_usdc()
│                   │
│  real: WalletAPI
│  mock: web3.py   │  ◄── 本次 demo 用 mock
└──────────────────┘
```

---

## 2. 每一步过程

```
STEP 1  Agent 发起初始请求
─────────────────────────
Agent
  → GET http://server/analyze
  → headers: (无特殊头)

x402 Server
  → 收到请求，检查 X-Payment-Proof
  → 不存在 → 返回 402

Response:
  HTTP 402
  {
    "x402": true,
    "pay_to": "0xSERVER...",
    "token": "0xUSDC...",
    "amount": 10000,          // 0.01 USDC (6位精度)
    "chain_id": 84532,        // Base Sepolia
    "nonce": 1748520000,
    "description": "Pay 0.01 USDC to access market analysis"
  }

---

STEP 2  Agent 解析付款要求，发给 BudgetGuard 检查
────────────────────────────────────────────────
Agent 解析 402 body 得到 pay_to / amount / token

BudgetGuard.check(
    requested_amount = 10000,
    requested_to     = "0xSERVER...",
    tx_nonce         = 1748520000
)

  → budget_remaining >= 10000 ?        ✓ 通过
  → "0xSERVER..." 在 allowed_addresses ?  ✓ 通过
  → nonce 未过期且在时间窗口内 ?        ✓ 通过

  → 返回 True，允许支付

---

STEP 3  CAW 执行链上 USDC 转账
────────────────────────────
CAW.transfer_usdc(to="0xSERVER...", amount=10000)

  → 构造 ERC-20 transfer transaction
  → 用 AGENT_PRIVATE_KEY 签名
  → 发送到 Base Sepolia 网络
  → 等待 receipt（链上确认）

  → tx_hash = "0xABC123..."

  区块链状态:
    USDC: AGENT_WALLET 扣减 10000
    USDC: SERVER_WALLET 增加 10000
    tx_hash 记录在链上

---

STEP 4  Agent 将 tx_hash 作为 proof 重试请求
──────────────────────────────────────────
Agent
  → GET http://server/analyze
  → headers: { "X-Payment-Proof": "0xABC123..." }

x402 Server 验证 proof:
  ① tx_hash 在已使用列表中 ?    → 否，继续
  ② 链上查询该 tx_hash receipt
  ③ receipt.status == 1 ?        → 交易成功
  ④ 从 logs 解码 Transfer event
     - to_address == SERVER_WALLET ?  ✓
     - amount >= 10000 ?             ✓
  ⑤ 通过 → 标记 tx_hash 为已使用（防 replay）

  → 返回 200

Response:
  HTTP 200
  {
    "result": "BTC/USDC trend: bullish. RSI=58...",
    "timestamp": 1748520060,
    "paid_with": "0xABC123..."
  }

---

STEP 5  审计日志持久化
──────────────────────
Agent 写审计记录到本地文件:

[2026-05-29T10:01:00Z] agent=0xAGENT... action=PAYMENT_INITIATED amount=0.01 USDC to=0xSERVER... chain=base-sepolia
[2026-05-29T10:01:03Z] agent=0xAGENT... action=BUDGET_CHECK      budget_remaining=0.99 USDC status=PASSED
[2026-05-29T10:01:08Z] agent=0xAGENT... action=CHAIN_TRANSFER     tx_hash=0xABC123... status=CONFIRMED block=12345678
[2026-05-29T10:01:09Z] agent=0xAGENT... action=PROOF_SUBMITTED    proof=0xABC123... server_status=200
[2026-05-29T10:01:09Z] agent=0xAGENT... action=PAYMENT_COMPLETED  data_received="BTC/USDC trend: bullish..."
```

---

## 3. 关键接口说明

### 3.1 x402 Server 端

```
GET /analyze
  无 X-Payment-Proof → 402 { x402, pay_to, token, amount, chain_id, nonce, description }
  有 X-Payment-Proof + 验证通过 → 200 { result, timestamp, paid_with }
  有 X-Payment-Proof + 验证失败 → 402 { error }

_verify_payment(tx_hash)
  → replay 检查（_used_proofs set）
  → 链上 receipt 查询
  → status == 1
  → 解码 Transfer event，验证 to 和 amount
  → 通过则加入 _used_proofs
```

### 3.2 CAW Client 端（Mock）

```
MockCAWClient.get_wallet_address()       → agent 地址
MockCAWClient.get_usdc_balance()        → USDC 余额（6位精度）
MockCAWClient.transfer_usdc(to, amount) → tx_hash

BudgetGuard.check(amount, to, nonce)    → boolean（需补充）
```

### 3.3 Agent 端

```
run()
  1. 检查余额
  2. GET /analyze → 收到 402
  3. 解析 payment_req
  4. BudgetGuard.check()（需补充）
  5. CAW.transfer_usdc()
  6. 用 tx_hash 重试 GET /analyze
  7. 收到 200 → SUCCESS
```

---

## 4. 风险边界

```
风险 1：重放攻击（Replay）
  → server.py 用 _used_proofs set 记录已用 tx_hash
  → 同一个 tx_hash 不能用第二次

风险 2：预算超支
  → BudgetGuard 在转账前检查 budget_remaining
  → 实际扣款是链上强制的（ERC-20 余额检查），双重保障

风险 3：Agent 越权操作
  → BudgetGuard 限制只能付给 allowed_addresses 白名单
  → 时间窗口外无法发起新支付（需重新授权）

风险 4：tx 失败但 Agent 不知道
  → caw_client.py 里 wait_for_transaction_receipt 失败则抛异常
  → agent.py 捕获异常，记录 FAILED，写入审计日志

风险 5：proof 验证失败后无法恢复
  → 当前设计：proof 验证失败（返回 402），agent 最多重试 1-2 次后放弃
  → 错误信息写入审计日志，不做自动修复
```

---

## 5. 现状评估

| 任务要求 | 状态 | 说明 |
|---------|------|------|
| x402 保护的 API | ✅ 达成 | server.py 完整实现 |
| Agent 发起请求、识别付款、完成支付 | ✅ 达成 | agent.py + caw_client.py 完整 |
| CAW / Pact 预算限制 | ❌ 缺失 | 无 BudgetGuard |
| CAW / Pact 操作范围限制 | ❌ 缺失 | 无地址白名单 |
| CAW / Pact 时间窗口 | ❌ 缺失 | 无时间窗口 token |
| Payment settlement | ⚠️ 部分 | 链上 USDC 转账已实现，但记录不持久化 |
| 可审计记录 | ❌ 缺失 | 无持久化日志 |
| 付款成功后获取结果 | ✅ 达成 | 重试拿 200 response |

---

## 6. 补充项清单

```
[ ] BudgetGuard 类 — caw_client.py
    - budget_remaining 属性
    - allowed_addresses 白名单
    - time_window 时间窗口
    - check(amount, to, nonce) → boolean

[ ] 审计日志模块 — agent.py
    - 每次 action 追加写入本地文件
    - 格式：[timestamp] agent= address action= type amount= status=

[ ] settlement 持久化 — server.py
    - _used_proofs 从内存 set 改为写文件
    - 进程重启后能恢复 replay 保护

[ ] 多端点展示 — server.py
    - /analyze（0.01 USDC，已有）
    - /deep-analysis（0.05 USDC，新增）

[ ] 真实 Cobo CAW SDK 集成
    - 替换 caw_client.py 内部实现
    - 保持 transfer_usdc() 方法签名兼容
```

---

## 7. 与 Agent-Payment-Commerce-Flow.md 的关系

本文档是 **执行层 demo**，对应 `Agent-Payment-Commerce-Flow.md` 设计文档中的：

```
x402 覆盖段落：
  STEP 1（报价/支付请求）  ← 对应 x402 PAYMENT-REQUIRED 响应
  STEP 2（预算授权检查）  ← 对应 BudgetGuard.check()
  STEP 3（链上执行）      ← 对应 CAW.transfer_usdc()
  STEP 4（交付验证）      ← 对应 server 验证 proof 后返回 200
  STEP 5（记录证明）      ← 对应审计日志

设计文档是"协议层应该怎么设计"，
本文档是"demo 层实际怎么跑起来"。
```
