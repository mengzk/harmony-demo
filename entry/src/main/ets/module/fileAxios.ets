/**
 * Author: Meng
 * Date: 2024/11/14
 * Modify: 2024/11/14
 * Desc: 文件上传
 */

import axios from '@ohos/axios';
import { FormData, AxiosResponse, AxiosProgressEvent, AxiosError } from '@ohos/axios';
import { fileIo as fs } from '@kit.CoreFileKit';
import { DialogHelper } from '@pura/harmony-dialog';

export interface UploadDto {
  code: number;
  msg: string;
  data?: string; // 单文件
  list?: Array<string>; // 多文件
}

// 返回格式
interface ResultDto {
  content: FileRes;
  success?: boolean;
  code: number;
  msg?: string
}

// 文件
interface FileRes {
  fid: string;
  fileUrl: string;
}

const instance = axios.create({
  timeout: 30000,
  // headers: {'Content-Type': 'application/json'}
});

const ossUrl = "https://oss-test.bnq.com.cn/api/fileUpload/uploadFileWithFileSuffix";

/**
 * 单文件上传
 */
export function axUpload(path: string): Promise<UploadDto> {
  if (path) {
    DialogHelper.showLoadingDialog({
      content: "上传中...",
      autoCancel: false
    });
    return axUploadFile(path).finally(() => {
      DialogHelper.closeLoading();
    });
  }
  return Promise.resolve({ code: -10, msg: '文件不能为空' } as UploadDto);
}

/**
 * 单文件上传
 */
export function axUploads(paths: Array<string>): Promise<UploadDto> {
  if (paths.length < 1) {
    return Promise.resolve({ code: -20, msg: '文件不能为空' } as UploadDto);
  }
  DialogHelper.showLoadingDialog({
    content: "上传中...",
    autoCancel: false
  });
  return new Promise((resolve) => {
    const imgs: string[] = [];
    Promise.all(paths.map((path) => axUploadFile(path)))
      .then((list) => {
        list.forEach((res) => {
          console.info("uploads all ------>", JSON.stringify(res));
          if (res.code == 0) {
            imgs.push(res.data || '');
          }
          // 处理上传失败文件
          // ...
          resolve({ code: 0, msg: 'ok', list: imgs });
        })
      })
      .catch((err: object) => {
        console.info("uploads err ------>", err);
        resolve({ code: -30, msg: '文件上传失败', list: [] });
      }).finally(() => {
      DialogHelper.closeLoading();
    });
  });
}

function axUploadFile(path: string): Promise<UploadDto> {
  console.info("uploadFile ------>", path);

  const filename = path.substring(path.lastIndexOf('/'));
  const formData = new FormData();

  formData.append('file', `internal://cache${filename}`)
  formData.append('bucket', 'bajanju-p');

  return instance.post<string, AxiosResponse<string>, FormData>(ossUrl, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    context: getContext(),
    onUploadProgress: (pro: AxiosProgressEvent) => {
      if (pro && pro.loaded && pro.total) {
        // console.log(Math.ceil(pro.loaded / pro.total * 100) + '%');
      }
    },
  }).then((res: AxiosResponse) => {
    console.log("uploadFile result: ", JSON.stringify(res.data));
    const data: ResultDto = res.data;
    if (data.success) {
      return { code: 0, msg: 'ok', data: data.content.fileUrl } as UploadDto;
    } else {
      return { code: -50, msg: data.msg || '文件上传失败' } as UploadDto;
    }
  }).catch((err: AxiosError) => {
    console.warn(`uploadFile error: ${err.code}, ${err.message}, ${err.name}, ${JSON.stringify(err.response)}`);
    return { code: -60, msg: err.message || '文件上传失败' } as UploadDto;
  });
}

/**
 * 删除文件
 * @param files
 */
export function axDelete(path: string) {

}

/**
 * 删除文件
 * @param files
 */
export function axDeletes(files: Array<string>) {

}

/**
 *  上传多文件
 */
function axUploadFiles(paths: Array<string>): Promise<UploadDto> {
  let formData = new FormData();
  formData.append('bucket', 'bajanju-p');

  paths.map((path) => {
    const filename = path.substring(path.lastIndexOf('/'));
    const filePath = `internal://cache${filename}`;
    console.info("file ------>", path, filePath);
    formData.append('files', filePath)
  })

  return axios.post<string, AxiosResponse<string>, FormData>(ossUrl, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    context: getContext(),
    onUploadProgress: (pro: AxiosProgressEvent) => {
      if (pro && pro.loaded && pro.total) {
        // console.log(Math.ceil(pro.loaded / pro.total * 100) + '%');
      }
    },
  }).then((res: AxiosResponse) => {
    console.log("result" + JSON.stringify(res.data));
    return { code: 0, msg: '' } as UploadDto;
  }).catch((err: AxiosError) => {
    console.warn(`--->error: ${err.code}, ${err.message}, ${err.name}, ${JSON.stringify(err.response)}`);
    return { code: 0, msg: '' } as UploadDto;
  });
}

export function axDownload(url: string, dir?: string, fileName?: string): Promise<string> {
  const context = getContext();
  let name = fileName || '';
  if (!fileName && url.includes('.')) {
    name = url.substring(url.lastIndexOf('/'));
    try {
      name = decodeURIComponent(name);
    } catch (e) {
      console.warn(`-----> download decodeURIComponent err`);
    }
  }
  // fs.mkdirSync(dir);
  let filePath = ((dir || '') ? dir : context.cacheDir) + name;
  try {
    fs.accessSync(filePath);
    fs.unlinkSync(filePath);
  } catch (err) {
    console.log('-----> download', JSON.stringify(err));
    // return Promise.resolve('');
  }
  DialogHelper.showLoadingDialog({
    content: "加载中...",
    autoCancel: false
  });
  return instance({
    url,
    context,
    filePath,
    method: 'get',
    // responseType: '',
    onDownloadProgress: (pro: AxiosProgressEvent) => {
      if (pro && pro.loaded && pro.total) {
        // console.log(Math.ceil(pro.loaded / pro.total * 100) + '%');
      }
    }
  }).then((res: AxiosResponse) => {
    // console.log("-----> download " + JSON.stringify(res.data), filePath);
    return filePath;
  }).catch((err: AxiosError) => {
    console.warn("-----> download error:" + JSON.stringify(err));
    return '';
  }).finally(() => {
    DialogHelper.closeLoading();
  });
}