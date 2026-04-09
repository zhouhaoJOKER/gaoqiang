import { ElNotification } from 'element-plus'
import { utils, writeFile } from 'xlsx'

/**
 * @description 接收数据流生成 blob，创建链接，下载文件
 * @param {Function} api 导出表格的api方法 (必传)
 * @param {String} tempName 导出的文件名 (必传)
 * @param {Object} params 导出的参数 (默认{})
 * @param {Boolean} isNotify 是否有导出消息提示 (默认为 true)
 * @param {String} fileType 导出的文件格式 (默认为.xlsx)
 * */
export const useDownload = async (
  api: (param: any) => Promise<any>,
  tempName: string,
  params: any = {},
  isNotify: boolean = true,
  fileType: string = '.xlsx'
) => {
  if (isNotify) {
    ElNotification({
      title: '温馨提示',
      message: '如果数据庞大会导致下载缓慢哦，请您耐心等待！',
      type: 'info',
      duration: 3000
    })
  }
  try {
    const res = await api(params)
    const blob = new Blob([res])
    // 兼容 edge 不支持 createObjectURL 方法
    if ('msSaveOrOpenBlob' in navigator)
      return (window.navigator as any).msSaveOrOpenBlob(blob, tempName + fileType)
    const blobUrl = window.URL.createObjectURL(blob)
    const exportFile = document.createElement('a')
    exportFile.style.display = 'none'
    exportFile.download = `${tempName}${fileType}`
    exportFile.href = blobUrl
    document.body.appendChild(exportFile)
    exportFile.click()
    // 去除下载对 url 的影响
    document.body.removeChild(exportFile)
    window.URL.revokeObjectURL(blobUrl)
  } catch (error) {
    console.log(error)
  }
}

/**
 * @description 导出excel
 * @param {Array} columns 导出的列 (必传)
 * @param {Array} tableData 导出的表格数据 (必传)
 * @param {String} fileName 导出的文件名 (必传)
 * */
export const exportExcel = (columns: any, tableData: any, fileName: string) => {
  const res: any = tableData.map((item: any) => {
    const arr: any = []
    columns.forEach((column: any) => {
      // 过滤多选列和操作列，并确保column.prop存在
      if (column.type != 'selection' && column.prop != 'operation' && column.prop) {
        arr.push(item[column.prop.replace('_cont', '')])
      }
    })
    return arr
  })
  const titleList: string[] = []
  columns.forEach((column: any) => {
    // 过滤多选列和操作列，并确保column.prop存在
    if (column.type != 'selection' && column.prop != 'operation' && column.prop) {
      titleList.push(column.label)
    }
  })
  res.unshift(titleList)
  const workSheet = utils.aoa_to_sheet(res)
  const workBook = utils.book_new()
  utils.book_append_sheet(workBook, workSheet, 'Sheet')
  writeFile(workBook, `${fileName}.xlsx`)
}
