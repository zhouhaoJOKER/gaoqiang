<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="500px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="100px">
      <ElFormItem v-if="props.provinceId" label="所属省">
        <span class="text-secondary">当前已选省</span>
      </ElFormItem>
      <ElFormItem v-else label="所属省" prop="province_id">
        <ElSelect
          v-model="form.province_id"
          placeholder="请选择省"
          filterable
          style="width: 100%"
          :disabled="props.readonly"
        >
          <ElOption v-for="p in provinceOptions" :key="p.id" :label="p.name" :value="p.id" />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="行政区划码" prop="code">
        <ElInput v-model="form.code" placeholder="行政区划码（唯一）" :readonly="props.readonly" />
      </ElFormItem>
      <ElFormItem label="市名称" prop="name">
        <ElInput v-model="form.name" placeholder="请输入市名称" :readonly="props.readonly" />
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
  import { listProvinceApi } from '@/api/province'
  import { createCityApi, updateCityApi, viewCityApi } from '@/api/city'

  interface Props {
    modelValue: boolean
    city?: any
    provinceId?: string | number
    defaultCode?: string
    readonly?: boolean
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    city: undefined,
    provinceId: undefined,
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
  const isEdit = computed(() => !!props.city?.id)
  const dialogTitle = computed(() => (isEdit.value ? '编辑市' : '新增市'))

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入市名称', trigger: 'blur' }]
  })
  const form = reactive({
    id: undefined as any,
    province_id: undefined as any,
    code: '',
    name: '',
    py: ''
  })
  const provinceOptions = ref<any[]>([])

  const loadProvinces = async () => {
    try {
      const res = await listProvinceApi({ per_page: 500 })
      const data = (res as any).data || []
      provinceOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      provinceOptions.value = []
    }
  }

  const loadDetail = async () => {
    if (!props.city?.id) return
    try {
      const res = await viewCityApi({ id: props.city.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        province_id: d.province_id,
        code: d.code ?? '',
        name: d.name ?? '',
        py: d.py ?? ''
      })
      await loadProvinces()
    } catch {
      ElMessage.error('加载失败')
    }
  }

  const handleSave = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const provinceId = props.provinceId ?? form.province_id
      if (!provinceId) {
        ElMessage.warning('请选择所属省')
        return
      }
      const params: any = {
        province_id: provinceId,
        code: form.code || undefined,
        name: form.name,
        py: form.py || undefined
      }
      if (isEdit.value) {
        await updateCityApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.city, ...params })
      } else {
        const res = await createCityApi(params)
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
    Object.assign(form, { id: undefined, province_id: undefined, code: '', name: '', py: '' })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (v) => {
      if (v) {
        if (props.provinceId) form.province_id = props.provinceId
        await loadProvinces()
        if (isEdit.value) await loadDetail()
        else {
          if (props.provinceId) form.province_id = props.provinceId
          form.code = props.defaultCode ?? ''
        }
      }
    }
  )
</script>
