/**
 * Author: Meng
 * Date: 2024/11/29
 * Modify: 2024/11/29
 * Desc: 文件预览
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/preview-arkts-V5
 */
import { filePreview } from '@kit.PreviewKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { picker } from '@kit.CoreFileKit';
import display from '@ohos.display';
import { common } from '@kit.AbilityKit';

import { axDownload } from '../module/fileAxios';

export async function openFile(path: string, context: common.Context) {
  const screen = display.getDefaultDisplaySync();
  let displayInfo: filePreview.DisplayInfo = {
    x: 1,
    y: 1,
    width: screen.width,
    height: screen.height,
  };
  const mimeType = getMediaType(path);
  let fileInfo: filePreview.PreviewInfo = { uri: path, mimeType };

  if (path.includes('https://')) {
    let dir = '';
    const res = await axDownload(path, dir);
    fileInfo.uri = `file:/${res}`;
  }

  console.log('------> ', JSON.stringify(fileInfo));

  filePreview.openPreview(context, fileInfo, displayInfo, (err) => {
    if (err && err.code) {
      console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
      return;
    }
    console.info('Succeeded in opening preview');
  });
}

// 多文件预览
export async function openFiles(urls: Array<string>, context: common.Context) {
  if (urls.length < 0) {
    console.log('----> 没有数据');
  } else if (urls.length == 1) {
    openFile(urls[0], context);
  } else {
    previewImgs(urls, context);
  }
}

// 多文件预览
export function previewImgs(urls: Array<string>, context: common.Context) {
  let list: Array<filePreview.PreviewInfo> = urls.map(uri => {
    const units = uri.split('.');
    return {
      uri,
      mimeType: `image/${units[units.length-1]}`
    } as filePreview.PreviewInfo;
  });
  console.log('------> ', JSON.stringify(list));
  filePreview.openPreview(context, list, 0).then((res) => {
    console.info('------> previewImg', JSON.stringify(res));
  }).catch((err: BusinessError) => {
    console.error(`------> previewImg err ${err.code}, ${err.message}`);
  });
}

function getMediaType(url: string): string {
  const strs = url.split('.');
  const name = (strs[strs.length - 1] || '').toLowerCase();
  switch (name) {
    case 'txt':
      return 'text/plain';
    case 'xml':
      return 'text/xml';
    case 'html':
    case 'htm':
      return 'text/html';
    case 'pdf':
      return 'application/pdf';
    case 'pptx':
    case 'xlsx':
    case 'docx':
      return '';
    default:
      return '';
  }
}

function getSavePath(name: string, context: common.Context) {
  let dir = '';
  // 创建文件管理器选项实例
  const options = new picker.DocumentSaveOptions();
  // 保存文件名（可选）
  options.newFileNames = [name];
  // 保存文件类型['后缀类型描述|后缀类型'],选择所有文件：'所有文件(*.*)|.*'（可选） ，如果选择项存在多个后缀，默认选择第一个。
  options.fileSuffixChoices = ['.pdf'];

  // 创建文件选择器实例。
  const documentViewPicker = new picker.DocumentViewPicker(context);
  //用户选择目标文件夹，用户选择与文件类型相对应的文件夹，即可完成文件保存操作。保存成功后，返回保存文档的URI。
  documentViewPicker.save(options).then((result: Array<string>) => {
    console.info('------> documentViewPicker:' + result);
    if(result.length > 0) {
      dir = result[0];
    }
  }).catch((err: BusinessError) => {
    console.warn(`------> documentViewPicker err ${err.code}, ${err.message}`);
  })
}