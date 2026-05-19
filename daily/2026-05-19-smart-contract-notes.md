# Smart Contract & Account Abstraction：知识总结

> 本笔记整合 Smart Contract 和 Account Abstraction 两章，以及 Network 和 DeFi & Oracle 概念。

---

## 一、Smart Contract（智能合约）

### 1.1 什么是智能合约

**通俗理解：** 链上的自动售货机
- 放钱进去（触发条件）
- 按按钮（调用函数）
- 东西掉出来（执行结果）

**特点：**
- 部署后任何人可调用
- 代码即法律，规则无法篡改
- 没有人能关掉它（去中心化）

### 1.2 部署（Deploy）

```
合约代码 → Solidity 编译 → 字节码 → 发送到链上
                                        ↓
                              获得合约地址（Contract Address）
```

**Remix JavaScript VM：** 本地模拟区块链，刷新后数据消失，适合练习。

### 1.3 调用（Call）

| 类型 | 关键词 | Gas | 说明 |
|------|--------|-----|------|
| 读取 | `view` / `pure` | 免费 | 只读，不修改链上状态 |
| 写入 | 普通函数 | 付费 | 修改状态，发交易 |

```solidity
function getGreeting() public view returns (string memory) {
    return greeting;  // 免费调用
}

function setGreeting(string memory newGreeting) public {
    greeting = newGreeting;  // 付费调用，消耗 Gas
}
```

### 1.4 状态（State）

状态变量存储在链上，持久化。

```solidity
contract HelloWorld {
    string public greeting = "Hello, Web3!";  // 状态变量，链上存储
    uint256 public counter = 0;  // 计数器
}
```

### 1.5 数据存储：memory vs storage

| 类型 | 含义 | 生命周期 |
|------|------|---------|
| `storage` | 永久存储（状态变量）| 链上持久化 |
| `memory` | 临时内存（局部变量）| 函数调用结束消失 |

```solidity
function getArray() public view returns (uint256[] memory) {
    uint256[] memory temp = myArray;  // 复制到 memory
    return temp;
}
```

### 1.6 函数可见性（Visibility）

```solidity
function foo() public { }      // 任何人都能调用
function foo() external { }    // 只能外部调用
function foo() internal { }   // 只能内部（合约自己 + 继承子合约）
function foo() private { }     // 只能本合约内部
```

**安全建议：** 状态变量不要轻易设 `public`，内部函数用 `internal` / `private`。

### 1.7 合约间调用

**方式 A：直接调用**

```solidity
OtherContract c = OtherContract(otherContract);
return c.getValue();
```

**方式 B：低层调用（更灵活）**

```solidity
(bool success, bytes memory data) = otherContract.call(
    abi.encodeWithSignature("getValue()")
);
```

### 1.8 事件（Events）

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);

function transfer(address to, uint256 amount) public {
    emit Transfer(msg.sender, to, amount);  // 触发事件，写入日志
}
```

**为什么重要：**
- Event 写入 Gas 便宜（只是日志）
- 状态变量写入 Gas 贵
- DApp 前端监听 Event 更新界面

### 1.9 错误处理

```solidity
function withdraw(uint256 amount) public {
    require(balance >= amount, "Insufficient balance");  // 推荐
    if (amount > maxWithdrawal) {
        revert("Amount exceeds maximum");
    }
    assert(amount > 0);  // 检查不应该发生的情况
}
```

### 1.10 继承（Inheritance）

```solidity
contract Animal {
    function eat() public pure returns (string memory) {
        return "eating";
    }
}

contract Dog is Animal {
    function bark() public pure returns (string memory) {
        return "woof";
    }
}
```

---

## 二、Account Abstraction（账户抽象）

### 2.1 EOA 的限制

| 问题 | 影响 |
|------|------|
| 必须有 ETH 才能发交易 | 新用户无法入门 |
| 私钥丢失 = 资产全丢 | 无法恢复 |
| 权限无法细分 | 不能只授权"每天转 100U" |
| 所有操作都要签名 | AI Agent 执行 100 笔 = 点 100 次 |

### 2.2 Smart Account（智能账户）

Smart Account 是一个**部署在链上的合约**，替代 EOA：

```
EOA：私钥 → 直接控制账户 → 发交易

Smart Account：
  私钥 → 签名 → 发消息给合约 → 合约规则判断 → 执行
```

**合约规则可以定义：**
- 多签（3 人里 2 人签名）
- 社交恢复（换个私钥）
- 消费限额（每天最多 100U）
- 过期时间（30 天后自动锁定）
- Gas 代付（别人帮你付）

### 2.3 ERC-4337：账户抽象标准

ERC-4337 是以太坊官方 Smart Account 标准。

**核心流程：**

```
UserOperation（用户操作）
    ↓ Bundler 打包
EntryPoint（入口合约）
    ↓ 验证 + 执行
Smart Account（你的账户合约）
    ↓
执行实际操作
```

**关键组件：**

| 组件 | 作用 |
|------|------|
| Smart Account | 你的账户合约，存你的规则 |
| EntryPoint | 统一入口，验证 UserOp 然后执行 |
| Bundler | 把多个 UserOp 打包成一笔交易 |
| Paymaster | 替别人付 Gas |

### 2.4 Session Key（会话密钥）

Session Key = 给 AI Agent 发的"临时门禁卡"：

```
用户授权 AI Agent：
  - 30 天内有效
  - 每天最多 500U
  - 只能操作特定合约

→ AI Agent 用 Session Key 签名
→ 合约验证这个 Key 有权限
→ 执行交易
```

**优点：**
- AI Agent 不知道主私钥
- 权限受限，不会被盗刷
- 过期自动失效

### 2.5 架构图

```
┌─────────────────────────────────────────┐
│  用户主私钥（绝对保密）                  │
└─────────────────────────────────────────┘
              ↓ 授权
┌─────────────────────────────────────────┐
│  Smart Account（合约规则）               │
│  - 多签？  - 消费限额？  - 过期时间？   │
└─────────────────────────────────────────┘
              ↓ 验证
┌─────────────────────────────────────────┐
│  Session Key（给 AI Agent 的临时权限）   │
│  - 只能操作白名单合约                    │
│  - 每日额度限制                          │
│  - 30天过期                              │
└─────────────────────────────────────────┘
              ↓ 执行
┌─────────────────────────────────────────┐
│  区块链（实际执行）                      │
└─────────────────────────────────────────┘
```

---

## 三、Network（网络层）

### 3.1 区块（Block）

```
区块结构：
┌──────────────────────────────────┐
│ Block Number, Hash, Timestamp    │
│ Previous Hash（连接上一区块）     │
│ Transactions Root（Merkle 树）   │
│ State Root（状态树）             │
│ Gas Used / Gas Limit             │
└──────────────────────────────────┘
        ↓
   ~12秒出一个块（以太坊 PoS）
```

### 3.2 共识机制（Consensus）

| | PoW（工作量证明）| PoS（权益证明）|
|--|-----------------|----------------|
| 原理 | 矿工用算力竞争记账权 | 验证者质押 ETH 竞争记账权 |
| 代表 | 比特币、以太坊经典 | 以太坊（2022年后）|
| 优点 | 安全经过时间验证 | 省电、确认更快 |
| 缺点 | 耗电高 | 复杂度更高 |

### 3.3 L2（Layer 2）

L2 是建在 L1 之上的扩容方案，继承 L1 安全性。

| | Optimistic Rollup | ZK Rollup |
|--|-------------------|-----------|
| 代表 | Arbitrum、Optimism | zkSync、StarkNet |
| 提现时间 | 7 天挑战期 | 几小时 |
| 原理 | 欺诈证明 | 零知识证明 |

### 3.4 RPC（Remote Procedure Call）

RPC = 你和区块链通话的接口。

```javascript
eth_blockNumber           // 查区块高度
eth_getBalance            // 查余额
eth_call                  // 读合约（免费）
eth_sendTransaction       // 发交易（付 Gas）
eth_sendRawTransaction    // 发送已签名交易
```

### 3.5 链上状态（On-chain State）

- 所有账户的余额
- 所有合约的存储
- Nonce（账户发出的交易计数）
- World State = 所有账户状态的根哈希

---

## 四、DeFi & Oracle

### 4.1 DeFi 核心模块

- **DEX（去中心化交易所）** — AMM 自动做市
- **Lending（借贷）** — Compound / Aave
- **Stablecoin（稳定币）** — USDT、USDC、DAI
- **Derivative（衍生品）** — 期权、期货

### 4.2 AMM（自动做市商）

```
流动性池：ETH + USDC
公式：x × y = k（恒定乘积）

有人买 ETH → 池里 ETH 变少 → 价格自动上涨
```

Uniswap 是 AMM 的代表。

### 4.3 借贷（Compound / Aave）

```
存 ETH 到 Compound
  ↓ ETH 作为抵押品（Collateral）
借出 USDC（稳定币）

抵押率：75%（存 100 ETH 可借 75 USDC）
利率：市场决定
清算：抵押品跌到阈值会被强制清算
```

### 4.4 Oracle（预言机）

**问题：** 区块链是封闭的，不知道链外世界发生了什么。

Oracle = 把链外数据（价格、天气、比赛结果）传上链的中间件。

| | 中心化 Oracle | 去中心化 Oracle |
|--|--------------|-----------------|
| 代表 | 单个数据源 | Chainlink |
| 风险 | 单点故障，可能造假 | 多节点共识，更可信 |
| 用途 | 低风险场景 | 高价值合约必须用 |

### 4.5 数据源风险

| 风险类型 | 例子 | 后果 |
|---------|------|------|
| Oracle 操纵 | 攻击者交易前操纵价格 | 预言机价格被操纵，清算 |
| 合约漏洞 | 代码 bug | 资金被偷 |
| 流动性风险 | 池子太小，价格滑点大 | 成交价格差 |

---

## 五、还没学的章节（待补充）

- [ ] Indexing（索引）— The Graph、链上数据整理
- [ ] Security（安全）— 合约/权限/模拟/监控风险
- [ ] Dev Stack（开发栈）— Hardhat、Foundry、wagmi

---

## 六、常见问题

**Q：智能合约和普通程序有什么区别？**
A：普通程序随时可改；合约部署后代码锁死（除非预留升级机制）。

**Q：Gas 在合约调用中怎么计算？**
A：每一步操作（存数据、循环、计算）都消耗 Gas。读取免费，写入按步骤付费。

**Q：EOA 和 Smart Account 哪个更好？**
A：取决于场景。EOA 简单兼容性好；Smart Account 功能更丰富（多签、社交恢复、权限细分）。

**Q：L2 和 L1 哪个更安全？**
A：L1 更安全（共识更强）。L2 继承 L1 安全性，但提现有挑战期。

**Q：DeFi 合约被盗了怎么办？**
A：很难追回。所以审计（audit）和风险监控非常重要。
