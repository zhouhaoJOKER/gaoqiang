<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="500px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="100px">
      <ElFormItem v-if="props.cityId" label="所属市">
        <span class="text-secondary">当前已选市</span>
      </ElFormItem>
      <ElFormItem v-else label="所属市" prop="city_id">
        <ElSelect
          v-model="form.city_id"
          placeholder="请选择市"
          filterable
          style="width: 100%"
          :disabled="props.readonly"
        >
          <ElOption v-for="c in cityOptions" :key="c.id" :label="c.name" :value="c.id" />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="行政区划码" prop="code">
        <ElInput v-model="form.code" placeholder="行政区划码（唯一）" :readonly="props.readonly" />
      </ElFormItem>
      <ElFormItem label="县/区名称" prop="name">
        <ElInput v-model="form.name" placeholder="请输入县/区名称" :readonly="props.readonly" />
      </ElFormItem>
      <ElFormItem label="拼音/检索" prop="py">
        <ElInput v-model="form.py" placeholder="拼音或检索" :readonly="props.readonly" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="handleCancel">取消</ElButton>
      <ElButton type="primary" @click="handleSave">保存</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { ElDialog, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton } from 'element-plus'
  import { listCityApi } from '@/api/city'
  import { createCountyApi, updateCountyApi, viewCountyApi } from '@/api/county'

  interface Props {
    modelValue: boolean
    county?: any
    cityId?: string | number
    defaultCode?: string
    readonly?: boolean
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    county: undefined,
    cityId: undefined,
    defaultCode: '',
    readonly: false
  })
  const emit = defineEmits<{
    (e: 'update:modelValue', v: boolean): void
    (e: 'created', p: any): void
    (e: 'updated', p: any): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (v) => emit('update:modelValue', v)
  })
  const isEdit = computed(() => !!props.county?.id)
  const dialogTitle = computed(() => (isEdit.value ? '编辑县/区' : '新增县/区'))

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入县/区名称', trigger: 'blur' }]
  })
  const form = reactive({
    id: undefined as any,
    city_id: undefined as any,
    code: '',
    name: '',
    py: ''
  })
  const cityOptions = ref<any[]>([])

  const loadCities = async () => {
    try {
      const res = await listCityApi({ per_page: 500 })
      const data = (res as any).data || []
      cityOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      cityOptions.value = []
    }
  }

  const loadDetail = async () => {
    if (!props.county?.id) return
    try {
      const res = await viewCountyApi({ id: props.county.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        city_id: d.city_id,
        code: d.code ?? '',
        name: d.name ?? '',
        py: d.py ?? ''
      })
      await loadCities()
    } catch {
      ElMessage.error('加载失败')
    }
  }

  const handleSave = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const cityId = props.cityId ?? form.city_id
      if (!cityId) {
        ElMessage.warning('请选择所属市')
        return
      }
      const params: any = {
        city_id: cityId,
        code: form.code || undefined,
        name: form.name,
        py: form.py || undefined
      }
      if (isEdit.value) {
        await updateCountyApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.county, ...params })
      } else {
        const res = await createCountyApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
      }
      dialogVisible.value = false
    } catch {
      /* empty */
    }
  }
  const handleCancel = () => {
    dialogVisible.value = false
  }
  const handleClosed = () => {
    Object.assign(form, { id: undefined, city_id: undefined, code: '', name: '', py: '' })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (v) => {
      if (v) {
        if (props.cityId) form.city_id = props.cityId
        await loadCities()
        if (isEdit.value) await loadDetail()
        else {
          if (props.cityId) form.city_id = props.cityId
          form.code = props.defaultCode ?? ''
        }
      }
    }
  )
</script>
