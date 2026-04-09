<template>
  <div class="preview-wrapper">
    <div class="preview-toolbar no-print">
      <ElButton type="primary" @click="handlePrint">
        <ArtSvgIcon icon="ri:printer-line" class="mr-1" />打印合同
      </ElButton>
    </div>

    <div ref="paperRef" class="a4-paper">
      <!-- 标题 -->
      <h1 class="paper-title">订购合同</h1>

      <!-- 头部信息 -->
      <table class="header-table">
        <tr>
          <td class="ht-label">合同编号：</td>
          <td class="ht-value ht-underline">{{ d.code || '' }}</td>
          <td class="ht-label" style="text-align: right">签订日期：</td>
          <td class="ht-value ht-underline">{{ formatDate(d.sign_at) }}</td>
        </tr>
      </table>

      <!-- 双方信息 -->
      <table class="party-table">
        <tr>
          <td class="pt-label">采 购 方：</td>
          <td class="pt-value">{{ d.client_name || '' }}</td>
          <td class="pt-label">供 应 方：</td>
          <td class="pt-value">{{ d.supplier_name || '' }}</td>
        </tr>
        <tr>
          <td class="pt-label">联 系 人：</td>
          <td class="pt-value">{{ d.client_contact_name || '' }}</td>
          <td class="pt-label">联 系 人：</td>
          <td class="pt-value">{{ d.supplier_contact_name || '' }}</td>
        </tr>
        <tr>
          <td class="pt-label">电&emsp;&emsp;话：</td>
          <td class="pt-value">{{ d.client_phone || '' }}</td>
          <td class="pt-label">电&emsp;&emsp;话：</td>
          <td class="pt-value">{{ d.supplier_phone || '' }}</td>
        </tr>
        <tr>
          <td class="pt-label">传&emsp;&emsp;真：</td>
          <td class="pt-value">{{ d.client_fax || '' }}</td>
          <td class="pt-label">传&emsp;&emsp;真：</td>
          <td class="pt-value">{{ d.supplier_fax || '' }}</td>
        </tr>
      </table>

      <p class="intro-text">
        经双方充分协商，<b>{{ d.client_name || '采购方' }}</b
        >兹确认向供应方订购如下产品：
      </p>

      <!-- 合同内容表格 -->
      <table class="contract-table">
        <tr>
          <td class="ct-label">英文品名</td>
          <td class="ct-value" colspan="3">{{ d.product_en || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">中文品名</td>
          <td class="ct-value" colspan="3">{{ d.product_zh || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">规格外观</td>
          <td class="ct-value ct-multiline" colspan="3">{{ d.specs || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">包装要求</td>
          <td class="ct-value ct-multiline" colspan="3">{{ d.pack_req || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">数&emsp;&emsp;量</td>
          <td class="ct-value"
            >{{ d.qty != null ? d.qty : '' }}{{ d.unit_name ? ` ${d.unit_name}` : '' }}</td
          >
          <td class="ct-label ct-label-inner">单&emsp;&emsp;价</td>
          <td class="ct-value">{{
            d.unit_price != null ? `¥${formatMoney(d.unit_price)}` : ''
          }}</td>
        </tr>
        <tr>
          <td class="ct-label">合计金额</td>
          <td class="ct-value" colspan="3">
            <span v-if="d.total != null">RMB{{ formatMoney(d.total) }}元</span>
            <span v-if="d.tax != null" class="ct-sub">&emsp;税额：{{ formatMoney(d.tax) }}</span>
            <span v-if="d.amount_net != null" class="ct-sub"
              >&emsp;不含税金额 {{ formatMoney(d.amount_net) }}</span
            >
          </td>
        </tr>
        <tr>
          <td class="ct-label">人民币大写</td>
          <td class="ct-value" colspan="3">{{ d.total_cn || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">交货时间</td>
          <td class="ct-value">{{ formatDate(d.deliver_at) }}</td>
          <td class="ct-label ct-label-inner">交货地点</td>
          <td class="ct-value">{{ d.deliver_addr || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">指标要求</td>
          <td class="ct-value">{{ d.indicator_req || '' }}</td>
          <td class="ct-label ct-label-inner">所需文件</td>
          <td class="ct-value">{{ d.req_docs || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label">结算方式</td>
          <td class="ct-value" colspan="3">{{ d.settlement_name || '' }}</td>
        </tr>
        <tr>
          <td class="ct-label ct-label-top">备注条款</td>
          <td class="ct-value ct-multiline ct-remarks" colspan="3">{{ d.remarks || '' }}</td>
        </tr>
      </table>

      <!-- 签章区 -->
      <table class="sign-table">
        <tr>
          <td class="sign-cell">
            <div class="sign-label">采购方签章：</div>
            <div class="sign-space" />
            <div class="sign-date">日期：</div>
          </td>
          <td class="sign-cell">
            <div class="sign-label">供应方签章：</div>
            <div class="sign-space" />
            <div class="sign-date">日期：</div>
          </td>
        </tr>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'

  const props = defineProps<{ data: Record<string, any> }>()

  const d = computed(() => props.data || {})
  const paperRef = ref<HTMLElement>()

  function formatDate(val: string | undefined): string {
    if (!val) return ''
    const date = new Date(val)
    if (isNaN(date.getTime())) return val
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const y = date.getFullYear()
    const m = date.getMonth() + 1
    const day = date.getDate()
    return `${y}/${m}/${day} ${weekdays[date.getDay()]}`
  }

  function formatMoney(val: number | string | undefined): string {
    if (val == null || val === '') return ''
    return Number(val).toLocaleString(undefined, {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }

  function handlePrint() {
    const el = paperRef.value
    if (!el) return
    const printWin = window.open('', '_blank', 'width=900,height=1200')
    if (!printWin) return
    printWin.document
      .write(`<!DOCTYPE html><html><head><meta charset="utf-8"><title>订购合同 - ${d.value.code || ''}</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: "SimSun", "宋体", serif; font-size: 12pt; color: #000; padding: 15mm 20mm; }
  .paper-title { text-align: center; font-size: 22pt; font-weight: bold; letter-spacing: 8pt; margin-bottom: 16pt; }
  table { width: 100%; border-collapse: collapse; }
  .header-table { margin-bottom: 6pt; }
  .header-table td { padding: 2pt 0; font-size: 11pt; }
  .ht-label { width: 80pt; white-space: nowrap; }
  .ht-value { }
  .ht-underline { border-bottom: 1px solid #000; }
  .party-table { margin-bottom: 6pt; }
  .party-table td { padding: 2pt 0; font-size: 11pt; }
  .pt-label { width: 72pt; white-space: nowrap; letter-spacing: 2pt; }
  .pt-value { }
  .intro-text { font-size: 11pt; margin-bottom: 8pt; line-height: 1.8; }
  .contract-table { border: 1.5px solid #000; margin-bottom: 12pt; }
  .contract-table td { border: 1px solid #000; padding: 5pt 8pt; font-size: 11pt; line-height: 1.6; vertical-align: top; }
  .ct-label { width: 72pt; text-align: center; font-weight: bold; white-space: nowrap; background: #f9f9f9; }
  .ct-label-inner { width: 72pt; text-align: center; font-weight: bold; white-space: nowrap; background: #f9f9f9; }
  .ct-label-top { vertical-align: top; }
  .ct-value { }
  .ct-multiline { white-space: pre-wrap; word-break: break-all; }
  .ct-remarks { min-height: 120pt; }
  .ct-sub { color: #333; }
  .sign-table { margin-top: 20pt; }
  .sign-table td { width: 50%; padding: 0 12pt; vertical-align: top; }
  .sign-label { font-size: 11pt; font-weight: bold; }
  .sign-space { height: 60pt; }
  .sign-date { font-size: 11pt; }
  @page { size: A4; margin: 15mm 20mm; }
</style></head><body>`)
    printWin.document.write(el.innerHTML)
    printWin.document.write('</body></html>')
    printWin.document.close()
    printWin.focus()
    setTimeout(() => {
      printWin.print()
      printWin.close()
    }, 400)
  }
</script>

<style scoped lang="scss">
  .preview-wrapper {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .preview-toolbar {
    display: flex;
    gap: 8px;
    justify-content: flex-end;
  }

  .a4-paper {
    width: 210mm;
    min-height: 297mm;
    padding: 15mm 20mm;
    margin: 0 auto;
    font-family: SimSun, '宋体', serif;
    font-size: 12pt;
    color: #000;
    background: #fff;
    border: 1px solid var(--el-border-color);
    border-radius: 2px;
    box-shadow: 0 2px 12px rgb(0 0 0 / 8%);
  }

  .paper-title {
    margin-bottom: 16pt;
    font-size: 22pt;
    font-weight: bold;
    text-align: center;
    letter-spacing: 8pt;
  }

  /* 头部信息 */
  .header-table {
    width: 100%;
    margin-bottom: 6pt;
    border-collapse: collapse;
  }

  .header-table td {
    padding: 2pt 0;
    font-size: 11pt;
  }

  .ht-label {
    width: 80pt;
    white-space: nowrap;
  }

  .ht-underline {
    border-bottom: 1px solid #000;
  }

  /* 双方信息 */
  .party-table {
    width: 100%;
    margin-bottom: 6pt;
    border-collapse: collapse;
  }

  .party-table td {
    padding: 2pt 0;
    font-size: 11pt;
  }

  .pt-label {
    width: 72pt;
    letter-spacing: 2pt;
    white-space: nowrap;
  }

  .intro-text {
    margin-bottom: 8pt;
    font-size: 11pt;
    line-height: 1.8;
  }

  /* 合同内容表格 */
  .contract-table {
    width: 100%;
    margin-bottom: 12pt;
    border-collapse: collapse;
    border: 1.5px solid #000;
  }

  .contract-table td {
    padding: 5pt 8pt;
    font-size: 11pt;
    line-height: 1.6;
    vertical-align: top;
    border: 1px solid #000;
  }

  .ct-label {
    width: 72pt;
    font-weight: bold;
    text-align: center;
    white-space: nowrap;
    background: #f9f9f9;
  }

  .ct-label-inner {
    width: 72pt;
    font-weight: bold;
    text-align: center;
    white-space: nowrap;
    background: #f9f9f9;
  }

  .ct-label-top {
    vertical-align: top;
  }

  .ct-multiline {
    word-break: break-all;
    white-space: pre-wrap;
  }

  .ct-remarks {
    min-height: 120pt;
  }

  .ct-sub {
    color: #333;
  }

  /* 签章 */
  .sign-table {
    width: 100%;
    margin-top: 20pt;
    border-collapse: collapse;
  }

  .sign-cell {
    width: 50%;
    padding: 0 12pt;
    vertical-align: top;
  }

  .sign-label {
    font-size: 11pt;
    font-weight: bold;
  }

  .sign-space {
    height: 60pt;
  }

  .sign-date {
    font-size: 11pt;
  }

  @media print {
    .no-print {
      display: none !important;
    }
  }
</style>
