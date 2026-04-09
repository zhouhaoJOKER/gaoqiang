<!-- 409页面 -->
<template>
  <ArtException
    :data="{
      title: '409',
      desc: $t('exceptionPage.409'),
      btnText: $t('exceptionPage.gohome'),
      imgUrl
    }"
  />
</template>

<script setup lang="ts">
  import imgUrl from '@imgs/svg/403.svg'
  defineOptions({ name: 'Exception409' })
</script>
