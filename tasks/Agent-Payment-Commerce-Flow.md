# Agent 帮人完成任务并收款：最小 Payment/Commerce Flow

> 本文档旨在设计一个最小可运行的 "Agent 帮人完成任务并收款" 的 Commerce Flow，基于真实协议（x402、ERC-8004、ERC-8183）构建。

---

## 1. 场景定义

### 1.1 选定场景：链上操作委托

**场景描述**：用户（Client）委托 AI Agent（Provider）执行链上操作（如 Swap、Mint、查询链上数据），用户支付报酬。

**典型案例**：DeFi 交易委托、数据查询服务、链上报告生成

### 1.2 角色映射

| 角色 | 描述 | 对应协议角色 |
|------|------|-------------|
| **Client（用户）** | 下单方/委托方，需要链上操作服务 | ERC-8183: client（创建 Job）|
| **Provider（Agent）** | 执行方，提供链上操作服务 | ERC-8183: provider（执行 Job）|
| **Evaluator（验收方）** | 验证工作是否完成，可以是用户自己或第三方 | ERC-8183: evaluator |
| **Facilitator（可选）** | 支付验证+链上结算的中介服务 | x402: facilitator |
| **Arbiter（仲裁方）** | 争议时介入裁决，可以是链上仲裁协议或人工 | 由 Job 合约的 hook 或外部仲裁合约充当 |

---

## 2. 完整 Commerce Flow

### 2.1 流程总览

```
报价(Quote)
    ↓
预算授权(Budget Authorization)
    ↓
执行(Execution)
    ↓
交付(Delivery)
    ↓
验收(Acceptance)
    ↓
付款/退款/争议(Payment / Refund / Dispute)
    ↓
记录证明(Attestation / Record)
```

### 2.2 详细流程

#### Step 1: 报价 (Quote)

**谁**：Provider（Agent）给出报价  
**做什么**：Agent 向 Client 报出完成指定任务的价格

```
Client → Agent: "帮我把 1 ETH 换成 USDC，找最优价格"
Agent → Client: 报价 0.005 ETH（~$10）
```

**机制**：
- Agent 通过 ERC-8004 注册文件公开自己的能力描述和价格
- Client 可以通过 Agent 的 `agentURI`（指向注册文件 JSON）查看服务类型和端点
- 报价可以通过 A2A/MCP 协议传递，也可以通过 x402 的 `PAYMENT-REQUIRED` 响应

---

#### Step 2: 预算授权 (Budget Authorization)

**谁**：Client 授权一笔预算  
**做什么**：Client 将资金锁定在 Escrow 中，等待 Agent 执行

**两种路径**：

**路径 A：基于 ERC-8183（智能合约 Escrow）**
```
Client → JobContract: createJob(provider, evaluator, expiredAt, description)
Client → JobContract: setBudget(jobId, budgetAmount)
Client → JobContract: fund(jobId, expectedBudget)
```
- 资金从 Client 转入 JobContract（托管合约）
- 状态变为 `Funded`
- 预算锁定，Agent 才能开始执行

**路径 B：基于 x402（支付授权模式）**
```
Client ← Server: 402 Payment Required + PAYMENT-REQUIRED header
Client → Server: 重新请求 + PAYMENT-SIGNATURE header（签名授权）
```
- Client 预先授权一笔 token 支出（通过 ERC-20 approval 或签名）
- Facilitator 验证支付授权有效性，但不立即链上结算

---

#### Step 3: 执行 (Execution)

**谁**：Provider（Agent）执行任务  
**做什么**：Agent 在链上执行操作，生成交付物

```
Agent: 执行指定的链上操作
  - 读取链上数据 / 执行 Swap / Mint NFT 等
  - 生成交付物（transaction hash, data results, proof）
Agent → Blockchain: 提交交易
Agent → JobContract: submit(jobId, deliverable)  [ERC-8183路径]
  或
Agent → Server: 返回执行结果 [x402路径]
```

**机制**：
- Agent 使用自己的钱包（由 ERC-8004 的 `agentWallet` 定义）执行链上操作
- 执行过程中的 gas 由 Agent 或 Client 承担（取决于协议约定）
- 可选：通过 Hook 机制在执行前后加入自定义逻辑（如 KYC 验证、保证金要求）

---

#### Step 4: 交付 (Delivery)

**谁**：Provider（Agent）交付结果  
**做什么**：将执行结果/证明提交给 Client 或合约

**ERC-8183 路径**：
```
Agent → JobContract: submit(jobId, deliverableHash)
- deliverable = bytes32（可以是 IPFS CID、ZK proof commitment、或 transaction hash）
- 状态: Funded → Submitted
```

**x402 路径**：
```
Agent → Client: 返回执行结果 + PAYMENT-SIGNATURE（已签名的支付授权）
- 在同一 HTTP 响应中附带支付 payload
```

---

#### Step 5: 验收 (Acceptance)

**谁**：Evaluator（验收方）检查交付物  
**做什么**：验证 Agent 提交的工作是否符合要求

```
Evaluator: 检查 deliverable 是否满足 job description
  - 通过链上合约调用 complete(jobId)  → 状态: Submitted → Completed
  - 或调用 reject(jobId, reason)       → 状态: Rejected/Refunded
```

**Evaluator 的三种形态**：
1. **Client 自己**：Client 直接调用 `complete` — 最简单场景
2. **第三方合约**：链上验证逻辑（如验证 ZK proof、验证价格落实）
3. **第三方人类/AI**：使用链下评价系统，最终通过合约完成结算

**超时机制**：
- 如果超过 `expiredAt` 仍未验收，任何人可以调用 `claimRefund(jobId)`
- 状态: Funded/Submitted → Expired，资金退还 Client

---

#### Step 6: 付款 / 退款 / 争议

##### 6.1 正常完成 → 付款

```
JobContract → Provider(Agent): 释放 escrowed funds
- 状态: Completed
- Provider 收到 budget（减去可选的平台手续费）
```

##### 6.2 被拒绝 / 超时 → 退款

```
JobContract → Client: refund (全额或按比例)
- 状态: Rejected 或 Expired
- Client 收回全部或部分资金
```

##### 6.3 争议 (Dispute)

**触发条件**：Evaluator 拒绝但 Client 认为已完成，或交付物质量争议

**机制**：
- **链上仲裁**：通过自定义 Hook 合约接入仲裁协议（如 Kleros、Snapshot Labs）
- **人工仲裁**：通过链下协议约定仲裁方，仲裁结果通过 Hook 执行
- **状态冻结**：争议期间资金锁定在合约中，直到仲裁完成

```
Dispute 场景：
  Client → Hook: 提出争议
  Hook → Arbiter: 转交争议
  Arbiter → Hook: 裁决（complete / reject / partial refund）
  Hook → JobContract: 执行裁决结果
```

---

#### Step 7: 记录证明 (Attestation / Record)

**谁**：记录已发生的商业事件  
**做什么**：生成不可篡改的完成证明，用于声誉系统、审计

**机制**：
- **ERC-8183 Event Log**：Job 的 `complete(jobId, reason)` 和 `reject(jobId, reason)` 事件自动记录在链上
- **ERC-8004 Reputation Registry**：Client 可以为 Agent 提交链上反馈（feedback），包括评分、服务质量指标
- **x402 Signed Receipt**：x402 提供 `Signed Offers & Receipts` 扩展，记录已签署的报价和支付结果

```
Agent(Provider) 收到完成反馈：
  Client → ReputationRegistry: giveFeedback(
    agentId,
    value,           // 评分（如 87/100）
    valueDecimals,   // 小数位
    tag1,            // 评价维度（如 "swap_accuracy"）
    feedbackURI,    // 指向详细评价文件的 IPFS 链接
    feedbackHash     // 文件完整性哈希
  )
```

---

## 3. 核心机制说明

### 3.1 资金托管（Escrow）机制

**ERC-8183 的 escrow 逻辑**：
- Client 调用 `fund(jobId)` 将预算 token 转入 JobContract
- 资金锁定直到：`complete`（付款给 Provider）或 `reject/expired`（退款给 Client）
- 防止 Provider 跑路，也防止 Client 赖账

**x402 的授权逻辑**：
- 不要求预充 Escrow，Client 通过签名授权令 Facilitator 代为结算
- 适合高频小额场景（ micropayments），通过 batch settlement 降低 gas

### 3.2 验收机制（Evaluator）

Evaluator 是 ERC-8183 的核心创新之一：
- **单一方裁定**：Evaluator 拥有 `complete` 和 `reject` 的唯一权限
- **可编程验证**：Evaluator 可以是智能合约，执行任意验证逻辑（如 ZK proof 验证）
- **防止双方串通**：即使 Client 和 Provider 合谋，没有 Evaluator 的签名也无法触发链上转账

### 3.3 Hook 机制（可扩展性）

ERC-8183 支持可选的 Hook 合约：
- `beforeAction`：`complete/reject` 等关键操作前执行自定义逻辑（如法律合规检查）
- `afterAction`：操作完成后执行副作用（如通知、声誉更新）
- **安全注意**：Hook 可以阻止操作，但 `claimRefund` 不经过 Hook，防止资金永久锁定

### 3.4 Agent 身份与发现（ERC-8004）

ERC-8004 解决"去哪里找 Agent"的问题：
- Agent 通过 ERC-721 NFT 注册到链上身份注册表
- `agentURI` 指向 JSON 注册文件，包含：
  - 服务端点（A2A、MCP、ENS、Email 等）
  - `x402Support`：是否支持 x402 支付
  - `supportedTrust`：支持哪些信任机制（reputation、TEE attestation、crypto-economic）
- 配合 Reputation Registry 实现基于历史表现的信任发现

### 3.5 支付与结算（x402）

x402 解决"如何付"的问题：
- 基于 HTTP 402 状态码，服务端宣告价格
- 三步握手：`PAYMENT-REQUIRED` → `PAYMENT-SIGNATURE` → `PAYMENT-RESPONSE`
- Facilitator 可以代为验证和链上结算
- 支持 batch settlement（高频场景下的批量链上结算，降低 gas）

---

## 4. x402 vs ERC-8183 对比

### 4.1 总体定位

| 维度 | x402 | ERC-8183 |
|------|------|---------|
| **解决的问题** | **支付**：如何让人付钱给服务 | **Commerce Flow**：如何组织整个任务委托-交付-验收-付款流程 |
| **层** | HTTP 协议层（应用层） | 智能合约层（协议层） |
| **核心概念** | 402 Payment Required、Facilitator | Job Escrow、Evaluator Attestation |
| **资金处理** | 签名授权 + Facilitator 代结算（或链上直结） | 合约托管（Escrow） |
| **适用场景** | API 付费、micropayments、AI agent 支付 | 复杂任务委托、链上任务外包、多方验收 |

### 4.2 各段职责对照

| Commerce Flow 阶段 | x402 负责哪段 | ERC-8183 负责哪段 |
|-------------------|-------------|------------------|
| **身份 / 发现** | ❌（无） | ERC-8004 提供 Agent 身份注册 |
| **报价 / 协商** | ⚠️（通过 402 响应包含价格信息）| ❌（无，协商在链下） |
| **预算授权 / 担保** | ⚠️（通过 token approval 或签名授权） | ✅（通过 fund() 将资金锁入 Escrow） |
| **执行** | ❌（执行本身不在 x402 范围内） | ❌（执行是 Agent 链上行为，合约只记录状态） |
| **交付 / 提交** | ⚠️（通过 HTTP response 返回结果） | ✅（通过 submit() 提交 deliverable） |
| **验收 / 验证** | ❌（无内置验收机制） | ✅（Evaluator 调用 complete/reject） |
| **付款 / 退款** | ✅（Facilitator 验证 + 链上结算） | ✅（合约自动转账或退款） |
| **仲裁 / 争议** | ❌（无内置争议机制） | ⚠️（通过 Hook 接入外部仲裁） |
| **记录证明** | ⚠️（Signed Receipt 提供交易证明） | ✅（Event log + Reputation Registry） |

### 4.3 互补关系

**最实用方案：x402 + ERC-8004 + ERC-8183 组合使用**

```
Client                    Agent                        JobContract              Facilitator
  |                         |                              |                        |
  | ──发现 Agent (ERC-8004 registry) ──→                  |                        |
  |                         |                              |                        |
  | ──请求服务 ───────────→ |                              |                        |
  | ←── 402 + 价格 ──────── |                              |                        |
  |                         |                              |                        |
  | ──授权预算 ───────────→ | ──fund() ──────────────────→ | ←─资金托管────────────  |
  |                         |                              |                        |
  |                         | ──submit() ───────────────→  |                        |
  |                         |                              |                        |
  | ←── 完成通知 ────────── | ←── complete() ───────────── | ←─Evaluator 裁决 ────  |
  |                         | ←── 付款 ─────────────────── |                        |
  |                         |                              |                        |
  | ──付钱 ─────────────────────────────────────────────→ | (x402 + Facilitator)    |
  |                         |                              |                        |
  | ←── 记录反馈 ─────────────────────────────────────── | (Reputation Registry)    |
```

**各协议职责分工**：
- **ERC-8004**：Agent 身份注册 + 发现 + agentWallet 设置
- **ERC-8183**：Job 生命周期管理 + Escrow 托管 + 验收机制
- **x402**：HTTP 层支付握手 + Facilitator 验证结算 + micropayment 支持
- **Reputation Registry（ERC-8004 子模块）**：完成后评价记录

### 4.4 关键差异详解

#### 4.4.1 支付 vs Commerce

**x402 本质上是一个支付协议**，解决"如何在 HTTP 请求中附带付款"的问题。它不关心：
- 任务是否已开工
- 工作成果是否符合预期
- 验收由谁完成

**ERC-8183 是一个 commerce 协议**，解决了任务委托中的信任问题：
- 预付资金托管防止 Agent 跑路
- Evaluator 机制防止 Client 赖账
- 明确的状态机保证资金不会卡住

**两者定位不同**：x402 适合简单的"付钱即得"场景（如付费 API 调用）；ERC-8183 适合需要验收的复杂任务外包。

#### 4.4.2 验证机制

**x402**：通过 Facilitator 验证 payment payload 的有效性（签名、余额、approval），验证通过即放行。

**ERC-8183**：通过 Evaluator 人工/合约判定工作成果，Evaluator 可以是 ZK proof 验证合约——这让 ERC-8183 支持比 x402 更复杂的验收逻辑（如"这个 Swap 是否以 ≤1%滑点完成"需要合约级别的价格验证）。

#### 4.4.3 争议处理

**x402**：没有内置争议机制，争议通过业务层解决（退款、仲裁协议）。

**ERC-8183**：争议可以通过 Hook 合约接入外部仲裁协议（如 Kleros），但核心合约本身只提供 `reject` 和 `claimRefund` 两条路径。

---

## 5. 最小实现建议

### 5.1 最简可行组合（Minimal Viable）

对于"Agent 执行链上操作并收款"的最简场景，推荐：

```
ERC-8004（身份） + ERC-8183（Job Escrow） + x402（HTTP 支付握手）
```

**为什么不只用 x402？**
x402 没有验收机制，Agent 可以收款后不干活，或提交劣质成果。ERC-8183 的 Escrow + Evaluator 机制解决了这个问题。

**为什么不只用 ERC-8183？**
ERC-8183 没有定义如何找到 Agent、如何发起支付请求。ERC-8004 提供了 Agent 发现机制，x402 提供了 HTTP 层支付握手。

### 5.2 具体部署建议

1. **Agent 注册**：部署 ERC-8004 Agent Registry，Agent mint NFT 并设置 `agentURI`
2. **Job 合约**：部署 ERC-8183 AgenticCommerce 合约（或带 Hook 的扩展版本）
3. **支付层**：集成 x402 Facilitator，处理 HTTP 402 握手和链上结算
4. **声誉层**：集成 ERC-8004 Reputation Registry，接收 Client 反馈

---

## 6. 参考资料

| 协议 | 关键概念 | 链接 |
|------|---------|------|
| x402 | HTTP 402 Payment Required, Facilitator, Batch Settlement | https://docs.x402.org/introduction |
| ERC-8183 | Job Escrow, Evaluator, Hook, Lifecycle (Open→Funded→Submitted→Completed) | https://eips.ethereum.org/EIPS/eip-8183 |
| ERC-8004 | Agent Identity, ERC-721 Registry, Reputation Registry, agentWallet | https://eips.ethereum.org/EIPS/eip-8004 |

---

## 7. 流程符号表示（ASCII 图）

```
Client                Agent                   JobContract           Evaluator            Facilitator
  |                     |                        |                     |                    |
  |--[Quote Request]----→|                        |                     |                    |
  |←--[Quote Response]---|                        |                     |                    |
  |                     |                        |                     |                    |
  |--[createJob]--------------------------------→|                     |                    |
  |--[setBudget]────────────────────────────────→|                     |                    |
  |--[fund(budget)]───────→|                     |                     |                    |
  |                     |                        |                     |                    |
  |                     |←--[Task Assignment]----|                     |                    |
  |                     |                        |                     |                    |
  |                     |--[Execute On-Chain]----→|                     |                    |
  |                     |                        |                     |                    |
  |                     |--[submit(deliverable)]→|                     |                    |
  |                     |                        |←--[Request Verify]---|                    |
  |                     |                        |                     |                    |
  |                     |                        |←--[complete/reject]--|                    |
  |                     |←--[Payment Released]---|                     |                    |
  |                     |                        |                     |                    |
  |←--[Result]----------|                        |                     |                    |
  |                     |                        |                     |                    |
  |←--[402+PAYMENT-REQUIRED]---------------------|                     |                    |
  |────────────────────────────────────────────────────────────────────────────────→|
  |                     |                        |                     |                    |
  |←--[Settled via Facilitator]------------------|                     |                    |
  |                     |                        |                     |                    |
  |--[giveFeedback]--------------------------------------------→      |                    |
  |                     |                        |                     |                    |
```

---

*文档版本：1.0 | 生成日期：2026-05-27*
