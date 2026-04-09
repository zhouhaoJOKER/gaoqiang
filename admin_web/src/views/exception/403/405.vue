<!-- 405页面 -->
<template>
  <ArtException
    :data="{
      title: '405',
      desc: $t('exceptionPage.403'),
      btnText: $t('exceptionPage.gohome'),
      imgUrl
    }"
  />
</template>

<script setup lang="ts">
  import imgUrl from '@imgs/svg/403.svg'
  defineOptions({ name: 'Exception405' })
</script>
