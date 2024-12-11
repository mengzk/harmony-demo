/**
 * Author: Meng
 * Date: 2024/11/09
 * Modify: 2024/11/09
 * Desc:
 */
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { axDownload, axDelete } from '../module/fileAxios'
import { FileArg, ReadArg } from '../pages/h5/model/args'

/**
 * 复制文件到缓存
 * @param path
 * @returns
 */
export function copyFileToCache(path: string): string {
  let name = path.substring(path.lastIndexOf('/'));
  try {
    name = decodeURIComponent(name);
  } catch (err) {
    console.warn('------> copyFileToCache', JSON.stringify(err))
  }
  const fileDir = `${getContext().cacheDir}${name}`;

  let file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
  // let file2 = fs.openSync(fileDir, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE); //先创建有读写权限的文件，再把不可读写的文件复制过来
  // fs.copyFileSync(file.fd, file2.fd);
  fileIo.copyFileSync(file.fd, fileDir);

  // 关闭文件
  fileIo.closeSync(file);
  // fs.closeSync(file2);
  return fileDir;
}

/**
 * 保存文件到本地
 * @param url
 * @param dir 必传参数
 * @param name
 */
export function saveFileToDisk(arg: FileArg) {
  const url = arg.url || "";
  const dir = arg.dir || ""; // 可指定默认files路径
  const name = arg.name || "";
  if (url.includes('https://') || url.includes('http://')) {
    axDownload(url, dir, name);
  } else if (arg.dataType == 'base64') {
    if (arg.data) {
      base64SaveToPhoto(arg.data, dir);
    }
  } else {

  }
}

/**
 * 读取本地文件
 * @param path
 * @param dir
 * @returns
 */
export async function readFileFromDisk(arg: ReadArg): Promise<string> {
  const path = arg.path;
  // const cacheDir = getContext().cacheDir;
  if (path) {
    // let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE);
    return getBase64FromPhoto(arg.path);
  }
  return '';
}

/**
 * 读取本地文件
 * @param path
 * @param dir
 * @returns
 */
export function deleteFileFromDisk(path: string) {
  try {
    if (path.includes('http://') || path.includes('https://')) {
      axDelete(path);
    } else {
      fileIo.unlinkSync(path);
    }
  } catch (err) {
    console.log('------> deleteFileFromDisk:', JSON.stringify(err));
  }
}

/**
 * 获取文档目录
 * @param name
 * @param context
 */
export function chooseDocumentPath(name: string, context: common.Context): Promise<string> {
  // 创建文件管理器选项实例
  const options = new picker.DocumentSaveOptions();
  // 保存文件名（可选）
  options.newFileNames = [name];
  // 保存文件类型['后缀类型描述|后缀类型'],选择所有文件：'所有文件(*.*)|.*'（可选） ，如果选择项存在多个后缀，默认选择第一个。
  options.fileSuffixChoices = [name.substring(name.lastIndexOf('.'))];
  // 创建文件选择器实例。
  const documentViewPicker = new picker.DocumentViewPicker(context);
  //用户选择目标文件夹，用户选择与文件类型相对应的文件夹，即可完成文件保存操作。保存成功后，返回保存文档的URI。
  return documentViewPicker.save(options).then((result: Array<string>) => {
    console.log('------> documentViewPicker:' + result);
    let dir = '';
    if (result.length > 0) {
      dir = result[0];
    }
    return dir;
  }).catch((err: BusinessError) => {
    console.warn(`------> documentViewPicker err ${err.code}, ${err.message}`);
    return '';
  })
}

/**
 * base64字符串转为图片并保存
 * @param data 需要转换的base64字符串
 */
export async function base64SaveToPhoto(data: string, dir: string): Promise<string> {
  let uri = ''
  try {
    let filePath = `${dir}/IMG${Date.now()}.png`;
    uri = fileUri.getUriFromPath(filePath);
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    const reg = new RegExp("data:image/\\w+;base64,");
    const base64 = data.replace(reg, "");
    const dataBuffer = buffer.from(base64, 'base64')
    fileIo.writeSync(file.fd, dataBuffer.buffer);
    console.log('-----> base64SaveToPhoto: ', uri);
    fileIo.closeSync(file);
  } catch (err) {
    console.warn('-----> base64SaveToPhoto err: ', JSON.stringify(err));
  }
  return uri;
}

/**
 * 图片转base64字符串
 * @param path 文件路径
 */
export async function getBase64FromPhoto(path?: string): Promise<string> {
  let base64 = ''
  if (path) {
    try {
      let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE);
      const ise: image.ImageSource = image.createImageSource(file.fd);
      const pixel = await ise.createPixelMap();
      if(pixel) {
        // 转换成base64
        const imagePackerApi: image.ImagePacker = image.createImagePacker();
        let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
        imagePackerApi.packing(pixel, packOpts).then((data: ArrayBuffer) => {
          let buf: buffer.Buffer = buffer.from(data);
          const base64 = 'data:image/jpeg;base64,' + buf.toString('base64', 0, buf.length);
          console.info('base64: ' + base64);
        })
      }
    } catch (err) {
      console.warn('-----> getBase64FromPhoto err: ', JSON.stringify(err));
    }
  }
  return base64;
}