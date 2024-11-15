/**
 * Author: Meng
 * Date: 2024/11/14
 * Modify: 2024/11/14
 * Desc: 文件上传
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/http-request-V5
 */
import request from '@ohos.request';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';

const ossUrl = "https://oss-test.bnq.com.cn/api/fileUpload/batchUploadWithFileSuffix";
const httpRequest = http.createHttp(); // 请求任务，不可复用

// 用于订阅HTTP响应头，此接口会比request请求先返回
// httpRequest.on('headersReceive', (header) => {
//   console.info('header: ' + JSON.stringify(header));
// });

/**
 * 单文件上传
 */
export function upload(path: string): Promise<string> {

  return new Promise((resolve) => {

  });
}

/**
 * 多文件上传
 */
export function uploads(paths: Array<string>): Promise<Array<string>> {

  return new Promise((resolve) => {
    if (paths.length < 1) {
      return;
    }

    console.log('------> uploads', JSON.stringify(paths));
    requestFile(paths.map(path => {
      const filename = path.substring(path.lastIndexOf('/'));
      const fileParam = filename.split('.');
      return {
        filename,
        name: fileParam[0],
        uri: `internal://cache/${filename}`,
        type: fileParam[1]
      } as request.File
    }))
    // request3(paths.map((path: string) => {
    //   const name = path.substring(path.lastIndexOf('/'));
    //   return {
    //     name: name.split('.')[0],
    //     contentType: 'image/png',
    //     filePath: path,
    //     remoteFileName: name
    //   } as http.MultiFormData;
    // }));
  });
}

function requestFile(formData: Array<request.File>) {
  let upProgressCallback = (uploadedSize: number, totalSize: number) => {
    console.info("upload totalSize:" + totalSize + "  uploadedSize:" + uploadedSize);
  };
  let headerCallback = (headers: object) => {
    console.info("upOnHeader headers:" + JSON.stringify(headers));
  };

  request.uploadFile(getContext(), {
    url: ossUrl,
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'multipart/form-data'
    },
    files: formData,
    data: [{ name: 'bucket', value: 'bajanju-p' }]
  })
    .then((uploadTask: request.UploadTask) => {
      // console.log('request upload:', JSON.stringify(uploadTask));
      uploadTask.on('progress', upProgressCallback);
      uploadTask.on('headerReceive', headerCallback);
    })
    .catch((err: BusinessError) => {
      console.warn(`request upload catch: ${err.code}, ${err.message}`);
    });
}

function request3(formData: Array<http.MultiFormData>) {

  httpRequest.request(ossUrl, {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'multipart/form-data' // application/json
    },
    // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
    extraData: JSON.stringify({ bucket: 'bajanju-p' }),
    // expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
    usingCache: true, // 可选，默认为true
    priority: 1, // 可选，默认为1
    connectTimeout: 30000, // 可选，默认为60000ms
    readTimeout: 30000, // 可选，默认为60000ms
    // usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
    usingProxy: false, // 可选，默认不使用网络代理，自API 10开始支持该属性
    multiFormDataList: formData
    // multiFormDataList: [// 可选，仅当Header中，'content-Type'为'multipart/form-data'时生效，自API 11开始支持该属性
    //   {
    //     name: "Part1", // 数据名，自API 11开始支持该属性
    //     contentType: 'text/plain', // 数据类型，自API 11开始支持该属性
    //     data: 'Example data', // 可选，数据内容，自API 11开始支持该属性
    //     remoteFileName: 'example.txt' // 可选，自API 11开始支持该属性
    //   },
    //   {
    //     name: "Part2", // 数据名，自API 11开始支持该属性
    //     contentType: 'text/plain', // 数据类型，自API 11开始支持该属性
    //     // filePath: `${getContext(this).filesDir}/fileName.txt`, // 可选，传入文件路径，自API 11开始支持该属性
    //     remoteFileName: 'fileName.txt' // 可选，自API 11开始支持该属性
    //   }
    // ]
  }, (err: BusinessError, data: http.HttpResponse) => {
    console.info('Result:' + JSON.stringify(data));
    if (!err) {
      // data.result为HTTP响应内容，可根据业务需要进行解析
      console.info('Result:' + JSON.stringify(data.result));
      console.info('code:' + JSON.stringify(data.responseCode));
      // data.header为HTTP响应头，可根据业务需要进行解析
      console.info('header:' + JSON.stringify(data.header));
      console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
    } else {
      console.error('error:' + JSON.stringify(err));
    }
    // 当该请求使用完毕时，调用destroy方法主动销毁
    httpRequest.destroy();
    // httpRequest.off('headersReceive'); // 取消订阅HTTP响应头事件
  });

}