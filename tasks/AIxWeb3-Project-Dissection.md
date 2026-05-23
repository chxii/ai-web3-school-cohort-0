# AI × Web3 项目拆解

---

## 项目一：x402

**x402 Foundation — HTTP 402 机器支付协议**

---

### 1. 它在解决什么问题

**核心问题：** AI Agent 需要付费调用别人的 API（天气数据、LLM 推理、区块链查询等），但现有的支付体系是为人类设计的——注册账号、填表单、绑信用卡、等审批。AI 不可能有银行卡，也不可能等人工审核。

x402 把支付嵌入 HTTP 请求本身（HTTP 402 = "Payment Required"），AI Agent 遇到 402 就自动付款、拿资源、走人，全程不需要人类介入。

**类比理解：** 就像给每个 HTTP 请求加了一个「投币口」，机器给机器打钱，毫秒级结算。

---

### 2. AI 部分是什么

- **AI Agent 作为付款方（Buyer）：** 当 AI 调用外部 API 时，x402 SDK 自动检测到 402 响应，从钱包扣款并重试请求。整个过程 AI 自主完成，不需要人类触发。
- **MCP Server 接入：** x402 文档里专门有 MCP Server 集成指南，意味着 AI Agent 可以通过 MCP 协议发现自己需要的工具，并自动为每次调用付 USDC。
- **支持多链钱包：** SDK 支持 EVM（viem）、Solana、Aptos、Algorand、Stellar——覆盖主流 AI Agent 运行环境。

AI 的价值在于**把「发现 → 支付 → 获取」变成全自动化闭环**，这在 AI Agent 经济里是基础设施级别的需求。

---

### 3. Web3 部分是什么

- **USDC 作为支付代币：** x402 主推 USDC（Circle 是 founding member），支持 EIP-3009（gasless transfer），付款由 Facilitator（C低 coinbase、Polygon 等）撮合，用户不需要有主网 ETH 也能付钱。
- **稳定币结算：** 避免了加密货币价格波动的问题，API 卖家收到的就是美元。
- **链上结算记录：** 每笔支付都有 tx_hash，可验证、可审计。
- **智能合约钱包支持：** 通过 EIP-712 签名 + EIP-1271 验证，智能合约钱包也能充当付款方（这意味着 Safe 多签钱包也可以给 AI 发预算、让 AI 自主支配）。

---

### 4. 可验证材料

| 材料 | 链接 |
|---|---|
| 官网 + 实时数据 | https://www.x402.org/（30 天：75M 笔交易，$24M Volume，22K 买家，94K 卖家）|
| GitHub | https://github.com/x402-foundation/x402 |
| 白皮书 | https://www.x402.org/x402-whitepaper.pdf |
| 文档 | https://docs.x402.org/ |
| Foundation 成员 | Adyen, Amazon, Amex, Circle, Cloudflare, Coinbase, Google, MasterCard, Shopify, Solana, Stripe, Visa 等 23 家 |
| 生产集成案例 | Stripe（USDC 收款）、Cloudflare Workers（原生支持）、AWS Lambda@Edge、Vercel AI Starter |

---

### 5. 判断与疑问

**判断：这是目前最接近「机器资本主义」的东西。** x402 不只是支付协议，它在解决一个根本性问题：AI Agent 经济如何用原生互联网方式付钱。Stripe 和 Visa 的加入说明传统支付巨头也在押注这个方向。

**最让人惊讶的一点：** x402 的交易笔数（75M/月）远超对"机器支付"的想象——说明已经有大量 AI 应用在跑生产流量，而不是停留在概念阶段。

**疑问：**
- Facilitator（Coinbase、Polygon）负责撮合和结算，它们收取多少费用？这是中心化风险吗？
- 如果 AI Agent 持有大量 USDC，私钥被盗怎么办？x402 有没有类似「授权额度」的限制机制？

---

## 项目二：ERC-8004（Trustless Agents）

**链上 AI Agent 身份与信誉注册表**

---

### 1. 它在解决什么问题

**核心问题：** AI Agent 互相发现、互相调用时，如何知道对方可信？传统的 MCP / A2A 协议解决了通信问题，但没有解决**信任传递**——你发消息给一个陌生 Agent，怎么知道它不会卷钱跑路、不会给你假数据？

ERC-8004 在链上建了三个注册表：

- **Identity Registry：** 基于 ERC-721，给每个 Agent 发一个 NFT 形式的链上身份证，指向一个 `agentURI`（存元数据：叫什么、能干什么、联系方式、支持哪些信任机制）。
- **Reputation Registry：** 任何人可以对 Agent 留评价（int128 评分 + 可选 tag），评价内容存在链上事件里，但不在合约 storage（节省 gas）。
- **Validation Registry：** 验证钩子——可以挂 stake 重跑、zkML 证明、TEE attestation 等多种验证方式。

---

### 2. AI 部分是什么

- **Agent 身份层：** 每个 AI Agent 有一个全局唯一标识 `eip155:1:0x742...:tokenId`，这个 ID 是跨链通用的（ERC-721 本身可移植）。
- **自我描述（AgentCard）：** `agentURI` 指向的 JSON 包含 Agent 的所有能力描述（MCP endpoint、A2A endpoint、ENS 域名、邮箱等），这是一个**机器可读的自我介绍**。
- **Endpoint 验证：** Agent 可以通过在域名根目录放一个 `.well-known/agent-registration.json` 来证明自己控制某个域名，防止伪造身份。
- **与 x402 联动：** ERC-8004 的 feedback 字段里专门留了 `proofOfPayment` 槽位，可以记录 x402 的支付证明——意味着「付过钱的 Agent 信誉更高」可以成为信任模型之一。

---

### 3. Web3 部分是什么

- **ERC-721 Identity：** 每个 Agent 是一个 NFT，owner 是管理员，可以给其他地址授权管理权限（operator）。转移 Agent ID 时 `agentWallet` 自动清零，强制重新验证。
- **EIP-712 + EIP-1271：** Agent 可以用智能合约钱包（Safe 等），通过合约签名证明自己是合法的钱包地址，而不只是 EOA。
- **Plug-and-play 信任模型：** 开发者可以选「仅看 reputation score」「要求 stake 重跑」「要求 zkML 证明」，安全级别按需配置。
- **支付隔离：** `agentWallet`（收钱地址）和 `owner` 地址分离，防止 Agent 被盗后攻击者直接卷走资金。

---

### 4. 可验证材料

| 材料 | 链接 |
|---|---|
| EIP 正式页面（Draft 状态）| https://eips.ethereum.org/EIPS/eip-8004 |
| 作者 | Marco De Rossi（MetaMask）、Jordan Ellis（Google）、Erik Reppel（Coinbase）等 |
| 依赖标准 | EIP-155（链 ID）、EIP-712（签名）、EIP-721（NFT 身份）、EIP-1271（合约签名）|
| ethskills 标注 | 声称 2026 年 1 月已在 20+ 链部署 |

⚠️ **注意：** EIP 页面显示 ERC-8004 目前是 **Draft（草稿）** 状态，不是 Final。ethskills 说已部署，两者存在差异——建议用 `cast code` 自行验证主网是否真有合约在跑。

---

### 5. 判断与疑问

**判断：ERC-8004 的野心比 x402 更大。** x402 只解决支付，ERC-8004 试图解决「机器社会的信任基础设施」。它的设计很聪明——把身份、信誉、验证拆成三个可插拔的模块，让市场自己决定哪种信任模型最好。但正因为它太通用，实际落地会需要更长时间。

**最有意思的设计细节：** reputation feedback 的 `tag1`/`tag2` 是完全开放的（字符串），没有任何预设值——这意味着未来可能出现专业化评价协议（比如专门评价 AI 诊断准确率的 `medical-diagnosis` tag），然后在上层构建评分聚合服务。这是一种**开放架构驱动创新**的思路。

**疑问：**
- Draft 状态的 EIP 真的在 20+ 链上部署了吗？还是 ethskills 的信息有延迟？
- 如果一个 Agent 的 `agentURI` 指向的 JSON 被悄悄改掉了（比如 DNS 被劫持），链上的 ERC-721 ID 本身不变，但元数据已经不可信了——这个攻击面有多大？
- reputation feedback 存在链上事件里，不在 storage 里——这对 indexer 友好，但有没有隐私问题？（差评会不会也被公开记录？）

---

## 总结对比

| | x402 | ERC-8004 |
|---|---|---|
| 解决的问题 | 机器之间怎么付钱 | 机器之间怎么互信 |
| AI 角色 | 付款方 / 服务消费者 | 服务提供方（也可能是消费者）|
| Web3 核心 | USDC 稳定币支付 + 链上结算 | ERC-721 身份 + 链上信誉事件 |
| 成熟度 | **生产级**（75M 笔/月，23 家成员）| 草稿阶段（Draft，落地待验证）|
| 与对方的关系 | ERC-8004 里专门留了 x402 支付证明槽位 | 两者天然互补——ERC-8004 负责信任，x402 负责支付 |

---

## 来源

- x402 官网：https://www.x402.org/
- x402 文档：https://docs.x402.org/
- x402 GitHub：https://github.com/x402-foundation/x402
- EIP-8004：https://eips.ethereum.org/EIPS/eip-8004
- ethskills：https://ethskills.com/
