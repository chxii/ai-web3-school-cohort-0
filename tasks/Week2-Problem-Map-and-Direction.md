# AI × Web3 问题地图

## 一、问题地图（6 个方向）

### 方向总览

```
┌──────────────────────────────────────────────────────────────────┐
│                     AI × Web3 问题空间                            │
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐             │
│  │  Payment    │   │  Identity  │   │   Wallet    │             │
│  │  机器支付   │   │  能力协作   │   │  权限控制   │             │
│  │  Commerce  │   │  Interop   │   │Safe Execu. │             │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘             │
│         │                 │                 │                    │
│    x402/USDC         ERC-8004/MCP       EIP-7702/              │
│    结算协议           链上身份           Session Key            │
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐             │
│  │  Privacy    │   │  Dev       │   │  Governance │             │
│  │  安全主权   │   │  Tooling   │   │  治理协作   │             │
│  │  Sovereignty│   │  工作流    │   │Public Goods│             │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘             │
│         │                 │                 │                    │
│    ZK+TEE             MCP/A2A          Snapshot/                │
│    隐私计算           开发者工具        OZ Defender              │
└──────────────────────────────────────────────────────────────────┘
```

---

### 1. Payment / Commerce / Settlement

**核心问题**：机器之间如何自动完成支付？

| AI 作用 | Web3 机制 |
|---------|----------|
| 自动决策触发支付（买 API/数据/算力）、毫秒级闭环、动态比价选最优路径 | USDC 稳定币结算、x402 协议（HTTP 402 机器支付）、EIP-3009 gasless transfer、链上 Escrow 托管 |

**关键标准**：
- x402 — 每月 7500 万笔机器间交易，23 家成员（Stripe/Visa/Cloudflare），生产级
- ERC-8183 — Job lifecycle 标准（Open → Funded → Submitted → Completed），Sepolia 已部署

**核心未解决问题**：AI 钱包风险控制（授权额度、异常检测）是采用最大瓶颈。

---

### 2. Identity / Reputation / Capability / Interoperability

**核心问题**：机器之间如何互信 + 协作？

| AI 作用 | Web3 机制 |
|---------|----------|
| 动态能力匹配、多 Agent 协调、任务协商与执行追踪 | 链上声誉（ERC-8004）、MCP/A2A 协议、ERC-721 NFT 身份、跨链 Agent ID |

**关键标准**：
- MCP（Anthropic）— Agent → 工具，564 个服务器，生产级
- A2A（Google）— Agent ↔ Agent 协作，推进中
- ERC-8004（⚠️ Draft）— 链上 Agent 身份，专门留了 x402 支付证明槽位

**核心未解决问题**：多 Agent 协作编排框架、Agent 能力验证防虚假。

---

### 3. Wallet / Permission / Safe Execution

**核心问题**：AI 能动多少钱，权限边界在哪里？

| AI 作用 | Web3 机制 |
|---------|----------|
| 动态判断（上下文决策）、异常检测、误触预防、用户代理 | Smart Account（Safe）、EIP-7702 + Session Key、ERC-6900 模块化账户、ERC-7579 最小接口标准 |

**关键数据**：
- 超过 25,000 个钱包已升级为 EIP-7702 智能账户（2026年初）
- Coinbase Agentic Wallet（2026-02）：首个专为 AI Agent 构建的钱包基础设施，使用 TEE 保护密钥
- AI 驱动攻击 2025 年激增 1,200%，损失 15.2 亿美元

**核心未解决问题**：Prompt Injection 防御（真实且严重，无成熟方案）。

---

### 4. Privacy / Security / Sovereignty

**核心问题**：AI 知道什么、暴露什么、被攻击损失多少？

| AI 作用 | Web3 机制 |
|---------|----------|
| 识别保护敏感信息、检测注入攻击、联邦学习隐私保护、ZK 证明生成 | 数据主权、开放记录抗审查、TEE 可信执行环境、零知识证明 |

**关键进展**：
- ZK+AI：Proof of Useful Attestation、FedRAG（延迟降 62 倍）
- TEE：ARM CCA 机密容器，从 VM 向容器演进
- Prompt Injection：AgentArmor（8层安全框架）、KYA（检测 89% 对抗探测）

**核心未解决问题**：ZK+AI 实用化、AI 输出不泄露链上隐私。

---

### 5. Dev Tooling / Agent Workflow

**核心问题**：开发者体验怎么被 AI 真正改善？

| AI 作用 | Web3 机制 |
|---------|----------|
| 自然语言查询链上数据、代码自动生成（Solidity）、合约安全分析 | 多链统一接口、The Graph 索引、MCP 协议连接链上工具、各链官方 AI SDK |

**关键生态数据（2026-05）**：
- MCP GitHub 仓库：564 个
- 热门：mcp-use（9994⭐）、awslabs/mcp（9122⭐）、solana-mcp（159⭐）、alchemy-mcp-server（86⭐）

**核心未解决问题**：自然语言到合约调用仍不可靠、AI 安全审计缺标准。

---

### 6. Governance / Coordination / Public Goods

**核心问题**：AI 如何辅助 DAO 做决策，不替代人？

| AI 作用 | Web3 机制 |
|---------|----------|
| 提案总结、投票建议、行动追踪、预算检查、会议行动项提取 | Snapshot 投票、OpenZeppelin Defender 自动化执行、链上治理分析 |

**现状**：AI 在治理中承担辅助角色，核心决策仍由人做。低参与率是根本问题，AI 无法解决。

**核心未解决问题**：低成本提案验证（结果和提案是否一致）。

---

## 二、为什么 Payment 和 Wallet 不是纯问题

### Payment

**为什么不是纯 AI 问题？**

AI 决策支付不难，但**信任谁、怎么保证资金安全释放、结果怎么验证**是 Web3 才能解决的。没有 Web3，AI 只能做模拟支付，不能做真实的价值结算。USDC 链上结算、x402 机器支付协议、Escrow 合约——这些是 AI 决策得以可信执行的保障。

**为什么不是纯 Web3 问题？**

x402 协议定义了机器支付接口，但**什么时候付、付多少、付给谁**需要 AI 根据上下文动态决策。传统支付是静态规则，AI 让支付成为推理链路的自然环节，实现毫秒级闭环。纯 Web3 做不了"按需触发 + 动态决策"的支付。

---

### Wallet

**为什么不是纯 AI 问题？**

AI 异常检测是辅助，但**权限必须由合约强制执行**——AI 被黑/被污染 ≠ 资产直接损失，Session Key 在合约层有严格限制。没有 Web3，AI 只能做检测（中心化风控），无法做到"AI 被污染时合约层兜底"的信任分离。

**为什么不是纯 Web3 问题？**

Session Key 机制是静态规则，但**动态判断"当前交易是否异常、是否应该执行"**需要 AI。没有 AI，钱包只能做规则匹配，无法识别新的攻击模式、无法根据上下文做模糊判断。

---

## 三、待决策：Week 2 主线方向

**候选：Payment / Commerce**

| 维度 | Payment | Wallet |
|------|---------|--------|
| 协议成熟度 | ✅ x402 生产级，SDK 就绪 | ⚠️ EIP-7702 新，Safe SDK 复杂 |
| 一周 Demo 难度 | 低（1-2 天出最小可行 Demo） | 中（Safe SDK 集成需要时间） |
| 核心风险 | 中（Facilitator 中心化） | 高（Prompt Injection 无解） |
| Hackathon 展示效果 | 清晰（支付 Dashboard 很直观） | 复杂（权限可视化不够直观） |

**Payment 的核心机会**：不是做支付协议，而是解决 AI Agent 持有资产后的**风控问题**——支付是刚需，安全是采用瓶颈。与 Wallet 方向的 Session Key 机制天然互补。

**待确认**：从"AI Agent 钱包的支付风控 Dashboard"切入，先做支付侧的最小 Demo，再视情况联动 Wallet 权限控制。

---

## 四、Reference

### Payment
- x402：https://www.x402.org/
- x402 文档：https://docs.x402.org/
- ERC-8183（Sepolia）：`0xE7cdb812E2dF3E2898D50b392bF1B3D072eE5d68`

### Wallet
- Safe：https://safe.global/
- EIP-7702：Pectra 升级（2025-05），生产级
- ERC-6900：https://eips.ethereum.org/EIPS/eip-6900
- ERC-7579：最小模块化智能账户接口标准
- Coinbase Agentic Wallet：2026-02 发布

### Identity
- ERC-8004：https://eips.ethereum.org/EIPS/eip-8004（⚠️ Draft）
- MCP：https://modelcontextprotocol.io/
- A2A：https://github.com/a2aproject/A2A

### Privacy
- AgentArmor：开源 8 层安全框架
- KYA (Know Your Agents)：检测 89% 对抗探测
- FedRAG：跨机构隐私 RAG，延迟降 62 倍

### Dev Tooling
- MCP 生态：564 个仓库（2026-05）
- mcp-use：https://github.com/mcp-use/mcp-use（9994⭐）
- alchemy-mcp-server：https://github.com/alchemyplatform/

### Governance
- Snapshot：https://snapshot.org/
- OpenZeppelin Defender：https://www.openzeppelin.com/defender
- DeepDAO：https://deepdao.io/

---

*文件来源：subagent research (2026-05-26)，综合本地知识库 + Web 搜索*
