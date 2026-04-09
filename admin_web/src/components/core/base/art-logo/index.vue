<!-- 系统logo -->
<template>
  <div class="flex-cc">
    <img :style="logoStyle" :src="logoUrl" alt="logo" class="w-full h-full" />
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'ArtLogo' })

  import { useSettingStore } from '@/store/modules/setting'

  const settingStore = useSettingStore()
  const { systemInfo } = storeToRefs(settingStore)

  const logoUrl = computed(() => systemInfo.value.logo || '/logo.png')

  interface Props {
    /** logo 大小 */
    size?: number | string
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 36
  })

  const logoStyle = computed(() => ({ width: `${props.size}px` }))
</script>
