/**
 * Author: Meng
 * Date: 2024/11/14
 * Modify: 2024/11/14
 * Desc: 文件上传
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/http-request-V5
 */

import axios from '@ohos/axios';
import { FormData, AxiosResponse, AxiosProgressEvent, AxiosError } from '@ohos/axios';
import { fileIo as fs } from '@kit.CoreFileKit';
import { UploadDto } from '../model/dtos'

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


const ossUrl = "https://oss-test.bnq.com.cn/api/fileUpload/uploadFileWithFileSuffix";

/**
 * 单文件上传
 */
export function axUpload(path: string): Promise<UploadDto> {
  if (path) {
    return axUploadFile(path);
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
      });
  });
}

function axUploadFile(path: string): Promise<UploadDto> {
  console.info("uploadFile ------>", path);
  return new Promise((resolve) => {
    const filename = path.substring(path.lastIndexOf('/'));
    const formData = new FormData();

    formData.append('file', `internal://cache${filename}`)
    formData.append('bucket', 'bajanju-p');

    axios.post<string, AxiosResponse<string>, FormData>(ossUrl, formData, {
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
        resolve({ code: 0, msg: 'ok', data: data.content.fileUrl });
      } else {
        resolve({ code: -50, msg: data.msg || '文件上传失败' });
      }
    }).catch((err: AxiosError) => {
      console.warn(`uploadFile error: ${err.code}, ${err.message}, ${err.name}, ${JSON.stringify(err.response)}`);
      resolve({ code: -60, msg: err.message || '文件上传失败' });
    })
  });
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
  const formData = new FormData();

  paths.map((path) => {
    const filename = path.substring(path.lastIndexOf('/'));
    const filePath = `internal://cache${filename}`;
    console.info("file ------>", path, filePath);
    formData.append('files', filePath)
  })

  formData.append('bucket', 'bajanju-p');

  return new Promise((resolve) => {
    axios.post<string, AxiosResponse<string>, FormData>(ossUrl, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      context: getContext(),
      onUploadProgress: (pro: AxiosProgressEvent) => {
        if (pro && pro.loaded && pro.total) {
          // console.log(Math.ceil(pro.loaded / pro.total * 100) + '%');
        }
      },
    }).then((res: AxiosResponse) => {
      console.log("result" + JSON.stringify(res.data));
    }).catch((err: AxiosError) => {
      console.warn(`--->error: ${err.code}, ${err.message}, ${err.name}, ${JSON.stringify(err.response)}`);
    })
  });
}

export function axDownload(url: string, dir?: string, fileName?: string): Promise<string|null> {
  const context = getContext();
  let name = fileName;
  if(!fileName && url.includes('.')) {
    name = url.substring(url.lastIndexOf('/'));
  }
  // fs.mkdirSync(dir);
  let filePath = (dir ? dir : context.cacheDir) + name;
  try {
    fs.accessSync(filePath);
    fs.unlinkSync(filePath);
  } catch (err) {
    console.log('------> download', JSON.stringify(err));
    return Promise.resolve(null);
  }
  return new Promise((resolve) => {
    axios({
      url,
      context,
      method: 'get',
      filePath: filePath,
      onDownloadProgress: (pro: AxiosProgressEvent) => {
        if (pro && pro.loaded && pro.total) {
          // console.log(Math.ceil(pro.loaded / pro.total * 100) + '%');
        }
      }
    }).then((res: AxiosResponse) => {
      console.log("result: " + JSON.stringify(res.data));
      resolve('')
    }).catch((err: AxiosError) => {
      console.warn("error:" + JSON.stringify(err));
      resolve(null);
    })
  });
}