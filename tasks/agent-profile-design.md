# Agent System 分析与 Profile 设计

---

## 一、熟悉的 Agent：Hermes Agent

### Identity

| 字段 | 内容 |
|------|------|
| **名称** | Hermes |
| **维护方** | Nous Research（开源，社区贡献） |
| **版本** | 2.1.0 |
| **类型** | 通用任务执行 Agent |
| **协议** | 自有协议（CLI/Gateway），MCP 兼容 |

---

### Capability

| 能力 | 说明 | 输入 | 输出 |
|------|------|------|------|
| terminal | 执行 shell 命令 | 命令字符串 | stdout/stderr + exit code |
| file | 读写/搜索/修改文件 | 路径 + 操作类型 | 文件内容或状态 |
| delegate_task | 派生子 Agent | goal + context + toolsets | 子 Agent 的 summary |
| cronjob | 调度定时任务 | schedule + prompt + delivery | 执行结果推送 |
| memory | 持久记忆跨会话 | key-value 事实 | 检索事实 |
| messaging | 跨平台发消息 | platform + target + content | 发送状态 |
| skills | 加载技能文档 | skill name | 执行步骤 + 命令 |
| mcp | 调用 MCP Server | server_name + tool + args | MCP tool result |

---

### 输入输出

输入：自然语言 prompt / slash command / config.yaml / skills / toolsets

中间：tool_calls → 外部执行 → JSON result

输出：文本回复 / 文件变更 / 平台消息 / 定时任务结果 / 子 Agent summary

---

### 协作对象

| 协作者 | 关系 | 协议 |
|--------|------|------|
| 子 Agent（派生） | 被调用方 | 内部 AIAgent loop |
| MCP Server | 工具供给方 | MCP（stdio） |
| Messaging Platform | 消息通道 | Feishu/Discord/TG 等 adapter |
| LLM Provider | 推理引擎 | OpenAI-compatible API |
| Cron Scheduler | 任务触发方 | 内部 scheduler |
| External Contract（ERC-8004/8183） | 身份/支付层 | 链上交互 |

---

### 失败点

| 失败场景 | 触发条件 | 处理方式 |
|----------|----------|----------|
| API Key 耗尽 | provider 返回 429/401 | credential pool 轮换；无备用则中断 |
| Tool Permission 拒绝 | destructive command 未批准 | 阻塞，等待用户 `/yolo` 或手动批准 |
| Context 溢出 | token 接近 limit | 自动触发 context compression |
| Subagent 超时 | `delegate_task` 5min 无响应 | 返回 partial summary，父 Agent 决定重试 |
| Gateway 断连 | 消息平台 WebSocket 断开 | 自动重连，cron 任务继续本地执行 |
| Skill 缺失 | 调用未安装的 skill | 返回错误，建议 `hermes skills install` |
| MCP Server 无响应 | `hermes mcp test` 失败 | 从 config 移除或修复 command/URL |

---

## 二、Agent Profile 设计：Web3 Analysis Agent

### 1. Identity —— 它是谁

| 字段 | 内容 |
|------|------|
| **名称** | Web3 Analysis Agent |
| **DID** | `did:ens:web3-analysis-agent.eth`（通过 ENS 注册，绑定链上地址） |
| **维护方** | W3A Labs（开发者团队），多签钱包控制升级权限 |
| **版本** | v1.2.0，版本 hash 锚定在 IPFS + EAS 链上证明 |
| **公钥** | Ed25519 公钥发布在 ENS text record，用于消息签名验证 |
| **注册表** | 链上 Agent Registry（参考 ERC-8004 思路），包含 DID、能力列表、收费地址、服务端点 |

### 2. Capability —— 它能做什么

| 能力 ID | 能力描述 | 类型 |
|---------|----------|------|
| `cap:read-chain` | 读取指定链上地址的交易历史、余额、合约状态 | 读取 |
| `cap:parse-tx` | 解析并用自然语言解释一笔交易的含义 | 分析 |
| `cap:summarize-doc` | 读取文档/白皮书/ABI，生成摘要 | 分析 |
| `cap:generate-report` | 生成结构化的链上活动报告，输出 Markdown 或 JSON | 输出 |

能力声明用 JSON-LD 格式发布，可被其他 agent 或用户读取后再决定是否调用。

### 3. 输入输出

**调用方式**：
- HTTP REST endpoint（同步，适合轻量任务）
- A2A Task 消息（异步，适合长任务 / 多步骤分析）
- 链上触发（用户在合约中发出任务请求，Agent 监听事件后响应）

**标准输入结构**：
```json
{
  "task_id": "uuid-xxxx",
  "caller_did": "did:ens:user.eth",
  "capability": "cap:parse-tx",
  "params": {
    "chain": "ethereum",
    "tx_hash": "0xabc..."
  },
  "payment_proof": "stripe-mpp-token OR on-chain-escrow-tx",
  "signature": "Ed25519-sig-by-caller"
}
```

**标准输出结构**：
```json
{
  "task_id": "uuid-xxxx",
  "status": "success | failed | partial",
  "result": { ... },
  "agent_signature": "Ed25519-sig-by-w3a",
  "attestation_uid": "EAS-attestation-uid-if-applicable",
  "error": null
}
```

输出结果可选择附带 EAS 链上证明（证明"W3A Agent 在某时间对某输入产生了某输出"），用于下游 reputation 积累。

### 4. 协作对象

Web3 Analysis Agent 在以下两个层次与外部系统协作：

**与工具协作（MCP 层）**：
- 通过 MCP 调用链上数据工具（如 Alchemy API、The Graph）获取原始数据
- 通过 MCP 调用文档解析工具处理白皮书、ABI 文件
- 工具是无状态的，Agent 维护上下文并决定调用顺序

**与链上合约协作（ERC-8004 / Registry 层）**：
- 将自己的能力声明注册在链上 Agent Registry，支持被其他 agent 或用户发现
- 将每次交付记录写入链上，积累可验证的历史记录和信誉

### 5. 收费方式

**计费模型**：按能力 + 用量计费

| 场景 | 收费单位 | 价格示例 |
|------|----------|----------|
| 单次交易解析（parse-tx） | 每次调用 | $0.05 / call |
| 文档摘要（summarize-doc） | 按文档长度 | $0.05–$0.20 |
| 报告生成（generate-report） | 按报告复杂度 | $0.10–$1.00 |

**支付流程**：
1. 用户调用前，Agent 返回报价（quote）
2. 用户通过 MPP 发起预付款，或链上锁定 escrow
3. Agent 执行任务
4. 成功后释放 escrow；失败则退款（依 SLA 定义）

收款地址绑定在 ENS / Agent Registry 中，不可伪造。

### 6. 如何被验证

验证分三个维度：

**身份验证**：
- 调用方通过 Agent 的 ENS 解析出公钥，验证响应消息的 Ed25519 签名
- 确认"这个响应确实来自 web3-analysis-agent.eth 控制的私钥"

**能力验证**：
- 能力列表发布在 Agent Registry，调用前可查询
- 能力声明版本锁定，防止静默降级

**交付验证**：
- 重要任务的输出附带 EAS attestation（链上证明）
- 证明内容：任务输入 hash + 输出 hash + 执行时间 + agent 签名
- 任何第三方可链上查询并验证这条证明的真实性
- 多次交付记录积累形成链上 reputation score

### 7. 失败处理

| 失败类型 | 原因示例 | 处理方式 |
|----------|----------|----------|
| 工具调用失败 | RPC 节点超时、API 限流 | 重试 3 次，超时后返回 `status: failed`，触发退款 |
| 输入非法 | 用户传入无效 tx hash 或不存在的文档 | 立即拒绝，返回错误码，不扣费 |
| 分析结果不完整 | 链上数据缺失导致报告残缺 | 返回 `status: partial`，说明缺失原因，部分退款 |
| Agent 自身崩溃 | 代码 bug、服务器宕机 | 链上 escrow 超时自动退款，无需 Agent 确认 |

**责任归属**：
- **Agent 自身 bug**：W3A Labs 多签负责退款，记入链上失败记录，影响 reputation score
- **用户输入错误**：不退费，输出中说明原因
- **第三方工具失败**（如 RPC 节点）：退款，记录为"外部依赖失败"，不计入 Agent reputation 扣分

SLA 写入链上合约，自动执行，不依赖 Agent 主观意愿。

---

## 三、MCP vs A2A 对比

这两个协议处于不同层级，解决的问题不同：

| 维度 | MCP（Model Context Protocol） | A2A（Agent-to-Agent） |
|------|-------------------------------|------------------------|
| 解决的问题 | Agent 与**工具/资源**的接口标准化 | Agent 与**另一个 Agent**的协作标准化 |
| 角色关系 | Client（Agent） ↔ Server（工具/数据源） | Peer-to-peer（两个 Agent 之间） |
| 类比 | USB 接口：统一设备连接标准 | HTTP 协议：两个服务之间的通信标准 |
| 传输 | stdio / HTTP（SSE） | JSON-RPC over HTTP/WebSocket |
| 上下文交换 | 工具 schema + 资源 + prompt 注入 | Task 分解 + 状态同步 + 结果返回 |
| 支付 | 不涉及 | 不涉及（但可叠加 ERC-8004） |
| 适用场景 | 给 Agent 添加"眼睛"（浏览器）"手"（文件/终端） | 多 Agent 协作：Planner + Executor + Critic |

**ERC-8004** 是另一层——解决链上 Agent 身份注册与发现，让 Agent 有 DID，可以被 lookup。

**MPP**（Machine Payment Protocol）是 Stripe 提出的，解决机器对机器的支付，跟 cron job delivery 结合自然——任务完成后触发 Stripe 收款。