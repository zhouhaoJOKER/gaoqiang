<template>
  <div class="privacy-policy">
    <div class="container">
      <h1 class="title">隐私权政策</h1>
      <p class="meta">
        更新日期：<strong>{{ updatedAt }}</strong>
        <span class="dot">·</span>
        生效日期：<strong>{{ effectiveAt }}</strong>
      </p>

      <p class="desc">
        欢迎您使用我们的产品与服务！我们深知个人信息对您的重要性，为帮助您了解我们如何收集、使用、共享与保护您的个人信息，以及您如何行使相关权利，我们制定本《隐私权政策》。在使用产品或服务前，请您仔细阅读并充分理解本政策。
      </p>

      <section class="section">
        <h2>一、适用范围</h2>
        <p
          >本政策适用于我们通过网站、客户端及随着技术发展出现的新形态向您提供的各项功能与服务。本政策不适用于第三方向您提供的产品或服务。</p
        >
      </section>

      <section class="section">
        <h2>二、信息收集及使用</h2>
        <p>为实现基础功能所必需，我们可能收集并使用下列类型的信息：</p>
        <ul>
          <li>账号信息：如用于注册或登录的手机号、账号名、头像、昵称等。</li>
          <li
            >设备与日志信息：如IP地址、设备型号、操作系统、浏览器类型、访问日期与时间、操作日志。</li
          >
          <li>功能相关信息：为实现即时通信、协作办公、个性化展示与安全防护所需的必要信息。</li>
        </ul>
        <p>如您拒绝提供实现基础功能所必需的信息，可能无法正常使用相应服务。</p>
      </section>

      <section class="section">
        <h2>三、共享、转移与公开披露</h2>
        <p
          >我们不会与任何公司、组织和个人分享您的个人信息，但以下情形除外：基于法定事由、依法履行法定义务、履行法律文书或行政执法要求、获得您明确授权等。发生合并、收购或破产清算情形时，我们将要求新的持有方继续受本政策约束或重新征得您的授权同意。</p
        >
      </section>

      <section class="section">
        <h2>四、您的权利</h2>
        <ul>
          <li>访问、更正与删除您的个人信息；</li>
          <li>撤回同意与注销账号；</li>
          <li>获取个人信息副本（在技术可行的前提下）。</li>
        </ul>
        <p>为保障安全，我们可能在处理您的请求前进行身份验证。</p>
      </section>

      <section class="section">
        <h2>五、信息的存储与安全</h2>
        <p
          >我们将在实现目的所必需的最短期间内保存您的个人信息，并采取符合行业标准的安全防护措施以防止信息的丢失、被不当使用及未经授权的访问或披露。</p
        >
      </section>

      <section class="section">
        <h2>六、政策的更新</h2>
        <p
          >当本政策发生重大变更时，我们将通过站内通知或弹窗等合理方式向您提示。继续使用即表示您已充分阅读、理解并同意受更新后的政策约束。</p
        >
      </section>

      <section class="section">
        <h2>七、未成年人保护</h2>
        <p
          >我们非常重视未成年人个人信息保护。若您为未成年人，请在监护人同意与指导下使用我们的服务。</p
        >
      </section>

      <section class="section">
        <h2>八、联系我们</h2>
        <p
          >如您对本政策有任何疑问、意见或建议，请通过产品内的客服渠道与我们联系，我们将在法定期限内予以回复。</p
        >
      </section>

      <section class="section">
        <div class="ref">
          <a class="link" href="#" target="_blank" rel="noopener noreferrer">访问官网</a>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'PrivacyPolicy' })

  // 可根据需要从后端配置化获取
  const updatedAt = '2025年9月5日'
  const effectiveAt = '2025年9月5日'
</script>

<style scoped lang="scss">
  .privacy-policy {
    padding: 40px 20px;
    color: var(--art-text-gray-900);
    background: var(--art-main-bg-color);
  }

  .container {
    max-width: 960px;
    margin: 0 auto;
  }

  .title {
    margin-bottom: 12px;
    font-size: 28px;
    font-weight: 500;
  }

  .meta {
    margin-bottom: 8px;
    color: var(--art-text-gray-600);

    .dot {
      margin: 0 8px;
    }
  }

  .desc {
    margin-bottom: 24px;
    color: var(--art-text-gray-600);
  }

  .section {
    margin-top: 24px;

    h2 {
      margin-bottom: 8px;
      font-size: 18px;
      font-weight: 600;
    }

    ul {
      padding-left: 18px;
      list-style: disc;
    }
  }
</style>
