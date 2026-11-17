# VIRTURA Apps 与协作网络实施计划

记录日期：2026-11-18。状态：0.1 源代码与会议预读；不是已经上线的账户服务，也不是已经通过的成员公约。

执行入口：[总控 #21](https://github.com/ewanqian/VIRTURA-SpacePort/issues/21)、[账户 #22](https://github.com/ewanqian/VIRTURA-SpacePort/issues/22)、[活动 #23](https://github.com/ewanqian/VIRTURA-SpacePort/issues/23)、[协作 #24](https://github.com/ewanqian/VIRTURA-SpacePort/issues/24)。

## 1. 已有积累与本轮边界

本轮真实检查到：`docs/design/spaceport-app-frontstage-design-system-v1.md`、`alpha.html`，以及 #6/#10/#12/#13/#14/#17/#20 的 Apps、站点、资源、Network Pass 和真实入口规划。不是从零构思。

早前对话提过本地 `spaceos.html`、`data/app-registry.json`，但本轮读取当前默认分支均返回 404；`pass/` 与 `pass/index.html` 也返回 404。不能把以前说过、本地生成或 README 列出的入口当作已部署功能。后续先查分支、本地与归档，再做路径映射，不删除旧档案。

本轮向 `VIRTURA-SPACEPORT/VIRTURA-Website` 创建 Issue 和分支均被集成拒绝（403）。当前计划和代码暂存在本仓库的独立分支，保持生产首页、域名与 main 不变。用户提出新建 `virtura-space`；完整目标 URL 与实际写权限尚未确认，不猜目标、不复制全仓、不迁移私有记录。

Supabase 插件已由用户连接并显示 installed=true；本轮工具发现尚未提供项目列表/SQL 执行入口。因此尚未选择项目、应用迁移、发送邮件或改变任何云端数据。

## 2. 一个品牌，两种产品，共用身份

- **VIRTURA Space / Apps**：公众内容与体验平台。入口像应用港口，不做通用桌面操作系统。免费内容可直接访问；收藏、继续进度、个人资源和活动关联才需要账户。
- **VIRTURA Collective**：内部项目型合作网络。成员自主、项目独立、财务按授权透明、公共资源共享。不是公众面板中的隐藏按钮，也不把所有公众注册者变成组织成员。
- **VIRTURA ID**：统一用户 UUID、个人资料与会话。账户、营销订阅、Collective 成员、项目角色、课程/资源权益分离。
- **个人 portfolio**：作者入口保持独立；仅选定 Apps/文章接入保存或审核留言，作品和客户不因接入账号转归团队。

VIRTURA 的商业合作入口保留为 Studio / Work with us，不因为发展内容平台就丢掉现有收入路径。应用商店首期是经过审核的第一方应用目录，不是第三方任意上传执行代码的市场。

## 3. 首波只交付三个公众入口

| 入口 | 用户能完成的动作 | 首版不做 |
| --- | --- | --- |
| 实时视听体验 | 无需头显，用鼠标/触屏/键盘进入一个已验收的音画实验；保存一个参数状态或结果 | 先不要求摄像头、AVP、复杂注册；不把不成熟音色当作成品 |
| Studio / Sessions | 看真实课纲、报名条件和排期；在 Luma 报名；活动后回到资料/练习 | 不自建会议音视频、票务、直播分发，不伪造报名/签到 |
| Library / Learning | 打开一条完整学习路径，收藏、继续阅读、下载有许可的练习资源 | 不先建十门空课程，不把未完成标记当认证证书 |

My VIRTURA 是三个入口共用的个人面板，不算第四套业务。MOVA/太空气球/林中茶屋沿用原 Station 身份，不因本表另建同名世界。数字收藏品只表示记录或明确许可的资源领取，不等于著作权转让、NFT 或投资权益。

首个供给建议为一次 Open Studio：一个真实演示、一次有限容量的共同操作/反馈、一份可带走的练习资料。负责人、版权与产能确认后才发布日程和价格。播客优先作为活动衍生，不新开高频制作义务。

## 4. 小前台，严格接口

新运行时可使用 Vite + TypeScript + React；旧静态站通过链接或局部接入保留，不要求先 React 重写。版本以 lockfile 固定；建立可复用但不过度拆包的模块：

```text
apps/public       公众入口和个人面板
apps/operations   内部后台，单独部署/访问边界
packages/ui       中文排版、焦点、对话框、错误/空态
packages/contracts 应用/资源/进度/权限的数据契约
packages/identity  认证适配器；不把服务端密钥送浏览器
packages/runtime3d 延迟加载的三维生命周期
supabase/migrations 与 tests 数据迁移和越权测试
```

目录结构是建议的未来目标，不是本次已经建成的系统。首版可以放同一代码仓，只有一个小应用；内外两套入口并不要求两套重复账户，也不能据此共用无限数据库访问权。

每个 App 的注册记录至少含稳定 ID、版本、来源/作者/许可、入口、发布状态、设备要求、图形档位、权限请求、状态数据版本和可卸载/清理方法。预览、本机、在线已验收三种状态不混用。

统一账号不等于跨域自动登录。同一平台下先统一登录；跨个人域名和多个应用的 OAuth/OIDC 后置，按客户端授权、严格回调、PKCE/state、会话撤销，不能把访问令牌放入 URL 或复制给 iframe。未知第三方应用用独立 origin、sandbox 和经过 origin 校验的消息契约，首期不开放第三方托管。

## 5. WebGPU 与强壮 WebUI

WebGPU 使用访客设备的 GPU，不需要先购买云 GPU。新三维模块可评估 three.js WebGPURenderer + TSL，提供 WebGL2 兼容路径，再提供静态预览。特定着色器/计算/材质是否可回退必须实际测试，不能以自动回退承诺全兼容。

三维运行时负责：能力探测、HTTPS、异步初始化、资源加载失败、设备丢失恢复或降级、分辨率/模型细节档位、内存清理、标签页隐藏时暂停。一次只激活一个重场景。普通阅读/账户页不加载三维引擎。WebXR 与 WebGPU 兼容性分开验收；没有头显仍可完成主要任务。

建议验收目标而非已测数据：桌面中档稳定约 60 fps，手机中档约 30 fps；实际定义测试设备后再计结果。先进入内容再加载高精素材，显示下载体积，提供取消/重试/低清选择。音频必须用户主动开启，保留静音和退出；多人音乐只同步参数/节拍，不用普通网络消息承担硬实时合奏。

UI 保持中文优先、克制的黑白暖灰、清晰对齐、既有标识和宽松留白。不靠频谱条、霓虹绿、随机卡片堆或不停转动的粒子证明技术。空间感属于内容体验，资料与表单保持可读。键盘焦点、屏幕阅读器、移动导航、减少动态效果、错误恢复是基础设施。

## 6. Luma 与日常/极限体验

日常：体验 App → 自愿保存 → 查看课纲/日历 → Luma 报名 → 经主办方核实的活动资料 → 下次继续。

扩展：现场作品/工作坊触发明确授权的数字资源领取；多个创作者发布节目/展览；用户通过同一个 ID 续接作品、参与项目或进入空间版本。大规模多人实时空间、云 GPU、直播转码/分发和开放交易不属于每月 50–100 元首版预算。

Luma 先作为官方公告、活动日历和预约入口。官方嵌入代码从真实活动后台取得，不猜 event ID。API 与 Webhooks 需 Luma Plus；未核实团队套餐，不新增订阅。收藏 != 报名 != 审核通过 != 签到；后续接入按事件/参与者稳定 ID 幂等同步，验证来源，处理重复/乱序/取消/退款和撤权，不擅自抓取或公开名单。

## 7. Supabase 配置与秘密

管理员 Supabase 账号管理项目；访客使用 VIRTURA ID，不需要注册 Supabase 管理账号。

- Project URL：形如 `https://<project-ref>.supabase.co`，不是网站首页。
- Publishable key：浏览器客户端可使用的项目标识，不代替 RLS。
- secret / service_role、数据库密码、SMTP 和 Luma API key：只放受控服务端，不发到聊天、Issue 或前端。
- Site URL：访客实际打开的网站 origin。
- Redirect URL：邮箱链接或身份登录后回到的实际页面，需要已实现回调处理。

开发阶段示例（只在本机开发确实使用此端口时）：

```text
Site URL: http://localhost:5173
Redirect URL: http://localhost:5173/auth/callback
```

未来生产建议（尚未部署，不能只填地址当作部署完成）：

```text
Site URL: https://account.virtura.space
Redirect URL: https://account.virtura.space/auth/callback
```

只允许精确回调；生产不要宽泛通配第三方域名。若配置 GitHub/Google 社交登录，对方后台常见的是 Supabase 提供的 `https://<project-ref>.supabase.co/auth/v1/callback`，它与本站回调不是一回事。首版邮箱 OTP 可减少链接跳转，但仍要验证邮件和会话流程。

Supabase 与 Vercel 连接只是可选部署/配置集成，不是使用 Supabase 的前置条件。默认邮件受限，仅适合测试；对外开放前配置自定义 SMTP、发信域名、限流和滥用防护。RLS、两用户越权测试、备份恢复完成前不得收真实敏感数据。

## 8. 每月 50–100 元预算

这是试运营预算上限，不是用量保证。美元仅按规划假设 1 USD=7 RMB 折算，不是实时汇率；未含税、域名续费、人员时间、支付手续费或超额费用。

- Cloudflare 静态资产：当前免费且不限静态请求；Worker 动态代码另计。Free 动态请求额度按官方限制执行。需要时 Workers Paid 从 $5/月起，约 35 元预算量级，不提前升级。
- Supabase Free：500 MB 数据库、1 GB 文件、5 GB egress 与 5 GB cached egress，50,000 MAU 是额度而非并发性能保证；低活跃可能暂停。Pro 从 $25/月起，约 175 元，单项已经超出当前预算。
- 邮件：Resend Free 当前 3,000/月且 100/日；必须测试用户邮箱送达，不把额度当成功发送能力。
- 大型公共素材：按需考虑 R2 Standard，当前 10 GB-month 免费，超额存储 $0.015/GB-month，操作次数单计；R2 出站不计费不等于整套服务无限免费。启用可能涉及付费账户，需先授权和告警。
- Vercel：不必增加。Hobby 定位个人非商业使用；不能为工作室商业平台默认使用它。Pro 从 $20/月起，超过 100 元预算量级。
- GitHub 保留代码、文档和 PR；账号/商业服务不以 GitHub Pages 作为长期交易/商业 SaaS 托管。

50 元档：尽量使用现有域名 + 免费静态托管/数据库/邮件，保留预算用于必要动态服务或备份。100 元档：仍不同时订阅多个 Pro；用于真实增长的存储/请求/备份余量。两档都能验证少量成员的收藏、进度、资料、活动闭环，不能据此承诺大型视频会议或万人在线。

中国内地方案可以评估国内轻量服务器或托管服务，但要看地区、内存、带宽、快照、数据库与续费总价，不拿新客年付活动折成永久月成本。不要为了便宜把完整 Supabase 栈塞入资源不足的机器；自托管增加补丁、邮件、安全、备份与恢复责任。

## 9. 中国内地公开运营前的检查

以下是上线检查，不替代针对实际主体与业务的法律意见。

中国内地 Web 托管应先通过接入商完成适用 ICP 备案，并核验域名实名、主体和服务内容。个人作品分享与团队商业/行业平台不是相同备案场景。收费内容、第三方市场、直播演出、出版或教育等应按真实业务核实是否触发许可/前置审批；不要把所有收费一概当同一类许可，也不要把备案当一张万能经营证。

海外托管不等于无合规责任。账号、邮箱、参与记录进入境外服务涉及个人信息处理与可能的数据出境；应明确数据目的/接收方/权利、适用的告知与同意、影响评估、删除和导出。2024 跨境规定对部分小规模非敏感信息场景有程序豁免，但并不取消其第十条的保护义务。国内前端 + 海外数据库仍需评估跨境与延迟。

1.0 优先第一方内容、无敏感信息、邀请测试；不先开放任意用户上传、公共评论、支付、直播或交易市场。移动端封装/小程序若另做，重新评估备案和平台规则。

## 10. 协作公约与会议

公约 v0.1 的十项原则见 #24 和 preview.html：自愿参与、个人权属、明确负责人、开工前约定、维护劳动计酬、分级账目透明、资源授权、争议处理、退出结算、版本更新。签署必须由真实用户对批准后的准确版本明确确认；本机表单不是签署。

项目提案卡至少含：目标、交付、范围、负责人、档期、角色报酬、资金来源、验收、变更、署名许可、风险和退出。项目账本分收入/成本/报酬/预留/事先约定的公共贡献；真实数据只在授权空间。

建议 45 分钟会议：10 分钟看可用入口，10 分钟确定首个活动/项目，15 分钟审公约和费用，10 分钟确认负责人、试用成员和验收。此处是预读，未创建日历邀请或声称会议已召开。

## 11. 从 1.0 到 5.0

1.0 一个公众体验 + 一条资料路径 + 一场活动；一个真实账号保存闭环；一次内部项目试运行。
2.0 学习路径与资源包、审核评论、创作者署名与内容发布。
3.0 多 Apps 标准注册/运行协议，逐应用身份授权、成熟 WebGPU/XR 档位。
4.0 已有复访需求后再引入付费节目/会员，订单/退款/到期撤权。
5.0 多创作者自主运营节目/项目、透明公共预算、可携带的记录与空间前台；不发行金融化积分。

从第一天固定用户/资源 ID、权限边界、版本迁移、导出和生命周期；不提前做全部未来页面和微服务。

## 12. 实施验收和交接

本分支仅新增文档、公告页、本机预览、适配器和 SQL。不得未经检查应用到已有数据库，不自动创建云项目，不购买服务、不改 DNS、不强推 main、不覆盖个人站。SQL 为一次性开发迁移，先在隔离项目测试。

上线前必须：两用户隔离/匿名拒绝、资源可见性、越权写入、版本冲突、撤销会话、跨设备恢复、备份恢复、邮件送达、手机浏览器、降级图形和实际域名回调测试。用户数据的删除/导出和成员权限撤销都要有可执行流程。

新仓库确认后，检查其 README/AGENTS/已有文件和实际权限，再把本分支新增模块通过 PR 接入。保留旧 Issue 链接和档案源；不要把个人资产、敏感账目和所有旧仓库一股脑搬过去。

## 官方参考（核查于 2026-11-18）

- https://threejs.org/manual/pages/webgpurenderer
- https://developer.mozilla.org/en-US/docs/Web/API/WebGPU_API
- https://supabase.com/docs/guides/getting-started/api-keys
- https://supabase.com/docs/guides/auth/redirect-urls
- https://supabase.com/docs/guides/auth/auth-smtp
- https://supabase.com/pricing
- https://developers.cloudflare.com/workers/platform/pricing/
- https://developers.cloudflare.com/r2/pricing/
- https://resend.com/pricing
- https://vercel.com/pricing
- https://vercel.com/docs/plans/hobby
- https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits
- https://help.luma.com/p/embed-luma-on-your-website
- https://help.luma.com/p/luma-api
- https://help.luma.com/p/webhooks
- https://help.aliyun.com/zh/icp-filing/basic-icp-service/product-overview/faq-about-icp-filing-applications-in-different-scenarios
- https://help.aliyun.com/zh/icp-filing/basic-icp-service/product-overview/limits
- https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm
