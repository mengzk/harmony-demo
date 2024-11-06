/**
 * Author: Meng
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc: h5与原生交互Api
 */
import File from '@system.file';
import { AlbumPickerComponent, AlbumPickerOptions, AlbumInfo} from '@kit.MediaLibraryKit';

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

import {EmitterOptions, PhotoOptions, MediaOptions} from '../dto/dto'

export default class H5Bridge {

  methodList = [];

  constructor() {
    this.getMethods(this);
  }

  getMethods(obj: H5Bridge) {
    // let props = [];
    // const curObj = ObjectConstructor.getPrototypeOf(obj);
    // if(curObj != null) {
    //
    // }
    // do {
    //   props = props.concat(Object.getOwnPropertyNames(curObj));
    //   curObj = Object.getPrototypeOf(obj);
    // } while (curObj);
    //
    // return props.sort().filter((e, i, arr) => {
    //   if (e != arr[i + 1] && typeof obj[e] == 'function') return true;
    // });
  }

  /**
   * 发送消息
   */
  emitter(options: EmitterOptions) {

  }

  /**
   * 拍摄照片
   */
  taskPhoto(options: PhotoOptions): Promise<string> {
    console.log('taskPhoto ---> options', options);

    return new Promise(resolve => {
      const date = Date.now();
      setTimeout(() => {
        resolve('结果' + date)
      }, 3000)
    });
  }

  choosePhoto() {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
    photoSelectOptions.maxSelectNumber = 5; // 选择媒体文件的最大数目
    let uris: Array<string> = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      console.info('photoViewPicker.select to file succeed and uris are:' + uris);
    }).catch((err: BusinessError) => {
      console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    })

  }

  /**
   * 获取相册
   */
  chooseMedia(options: MediaOptions): Promise<File> {
    // 用于相册组件初始化时设置参数信息
    const albumOptions: AlbumPickerOptions = new AlbumPickerOptions();

    console.log('----->', options);
    return new Promise(resolve => {
      AlbumPickerComponent({
        // 设置组件选择选项实例
        albumPickerOptions: albumOptions,
        /**
         *相册被选中回调，返回相册信息
         * AlbumInfo（uri）
         */
        onAlbumClick: (albumInfo: AlbumInfo): boolean => {
          if (albumInfo?.uri) {
            // 根据相册url更新宫格页内容
            console.log('AlbumPicker ----->', albumInfo.uri)
          }
          return true;
        },
      })

      resolve([]);
    });
  }

  /**
   * 报打电话
   */
  callPhone() {

  }

  /**
   * 预览图片
   */
  previewImage() {

  }

  /**
   * 预览文档
   */
  previewDocs() {

  }

  /**
   * 获取位置
   */
  getLocation() {

  }

  /**
   * 扫码
   */
  qrcodeScan() {

  }


  /**
   * 用户信息
   */
  userInfo() {

  }

  /**
   * 设备信息
   */
  deviceInfo() {

  }

  /**
   * 分享
   */
  share() {

  }

  /**
   * 收银台
   */
  cashier() {

  }

  test(): string {
    console.log('--------> test');
    return "test";
  }

  toast(): void {
    console.log('--------> toast');
  }

  asyncTest(testStr:string): Promise<string> {
    console.log('--------> async Test' + testStr);
    return new Promise(resolve => {
      const date = Date.now();
      setTimeout(() => {
        resolve('结果' + date)
      }, 3000)
    });
  }
}