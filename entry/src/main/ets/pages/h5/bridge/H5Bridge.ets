/**
 * Author: Meng
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc: h5与原生交互Api
 */
import File from '@system.file';
import { emitter } from '@kit.BasicServicesKit';
import { AlbumPickerComponent, AlbumPickerOptions, AlbumInfo } from '@kit.MediaLibraryKit';

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

import { Latlng, DeviceDto, UserDto, MediaDto, } from '../model/dtos';
import {
  EmitArg,
  CameraArg,
  PhotoArg,
  MediaArg,
  AudioArg,
  PlayArg,
  PreviewArg,
  FolderArg,
  SettingArg,
  LocationArg,
  LinkArg,
  ShareArg,
  ShareItem,
  PayArg,
  NavArg,
  RouteArg,
  PageArg,
} from '../model/args'
import { promptAction } from '@kit.ArkUI';

export default class H5Bridge {
  methodList: Array<string> = [];

  constructor() {
    this.getMethods(H5Bridge);
  }

  getMethods(obj: ESObject) {
    const filterKey = ['constructor', 'getMethods', 'destroy'];
    let keys = Object.getOwnPropertyNames(obj.prototype);
    keys = keys.filter((key: string) => typeof obj.prototype[key] === 'function' && !filterKey.includes(key));
    keys.forEach(e => {
      console.log('--->', e);
    })

    this.methodList = keys;
  }

  /**
   * ❗️调用方法
   */
  invoke(name: string, data: object) {

  }

  /**
   * 发送消息
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-emitter-V5#emitteremit
   */
  emit(arg: EmitArg) {
    console.log('emit --->', JSON.stringify(arg));
    // emitter.on("eventId",  (data: emitter.GenericEventData<string>) => {});
    // emitter.once("eventId",  (data: emitter.GenericEventData<string>) => {});
    // emitter.off("eventId");
    // const eventData = emitter.EventData = { data: '123456' }
    // emitter.emit("eventId", { data: '123456' });

    emitter.emit('web-page', {
      data: arg
    })
  }

  /**
   * 添加消息监听
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-emitter-V5#emitteremit
   */
  listener(arg: EmitArg) {
    console.log('listener --->', JSON.stringify(arg));
    // emitter.on("eventId",  (data: emitter.GenericEventData<string>) => {});
    // emitter.once("eventId",  (data: emitter.GenericEventData<string>) => {});
    // emitter.off("eventId");
    // const eventData = emitter.EventData = { data: '123456' }
    // emitter.emit("eventId", { data: '123456' });
    const onEvent = (data: emitter.GenericEventData<object>) => {
      console.log('listener ------> ', data.data);
    }
    if (arg.once) {
      emitter.once(arg.event, onEvent);
    } else {
      emitter.on(arg.event, onEvent);
    }
  }

  /**
   * 移除消息监听
   */
  remove(arg: EmitArg) {
    console.log('remove --->', JSON.stringify(arg));
    emitter.off(arg.event);
  }

  /**
   * 用户信息
   */
  userInfo(): UserDto {
    return {};
  }

  /**
   * 退出账号
   */
  logout() {

  }

  /**
   * 登录账号
   */
  login(tag: string): Promise<UserDto> {
    return new Promise(resolve => {
      resolve({});
    });
  }


  /**
   * 设备信息
   */
  deviceInfo(): DeviceDto {
    return {
      width: 0,
      height: 0,
      top: 0,
      bottom: 0
    };
  }

  /**
   * 获取应用信息
   */
  screenInfo() {

  }

  /**
   * 打开摄像头 拍照/录像
   */
  openCamera(arg: CameraArg): Promise<string | File> {
    console.log('taskPhoto ---> Args', arg);

    return new Promise(resolve => {
      const date = Date.now();
      setTimeout(() => {
        resolve('结果' + date)
      }, 3000)
    });
  }

  /**
   * 选择照片
   */
  choosePhoto(arg: PhotoArg): Promise<MediaDto> {

    const photoSelectArgs = new photoAccessHelper.PhotoSelectOptions();
    photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
    photoSelectArgs.maxSelectNumber = 5; // 选择媒体文件的最大数目
    let uris: Array<string> = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectArgs).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      console.info('photoViewPicker.select to file succeed and uris are:' + uris);
    }).catch((err: BusinessError) => {
      console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    })

    return new Promise(resolve => {
      const date = Date.now();
      setTimeout(() => {
        resolve({});
      }, 3000)
    });
  }

  /**
   * 获取媒体文件
   */
  chooseMedia(arg: MediaArg): Promise<MediaDto> {
    // 用于相册组件初始化时设置参数信息
    const albumArgs: AlbumPickerOptions = new AlbumPickerOptions();

    console.log('----->', arg);
    return new Promise(resolve => {
      AlbumPickerComponent({
        // 设置组件选择选项实例
        albumPickerOptions: albumArgs,
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

      resolve({});
    });
  }

  /**
   * 预览图片
   */
  previewImage(arg: PreviewArg) {

  }

  /**
   * 预览文档
   */
  previewDocs(arg: PreviewArg) {

  }

  /**
   * 打开文件夹
   */
  openFolder(arg: FolderArg) {

  }

  /**
   * 打开设置
   */
  openSetting(arg: SettingArg) {

  }

  /**
   * 打开其他App
   */
  openApp(arg: LinkArg) {

  }

  /**
   * 报打电话
   */
  callPhone(phone: string) {

  }

  /**
   * 发送短信
   */
  sendSms(phone: string, msg: string) {

  }

  /**
   * 获取位置
   */
  getLocation(arg: LocationArg): Promise<Latlng> {
    return new Promise((resolve) => {

      resolve({
        lat: 0, lng: 0
      });
    });
  }

  chooseAddress(): Promise<Latlng> {
    return new Promise((resolve) => {
      resolve({
        lat: 0, lng: 0
      });
    });
  }

  /**
   * 扫码
   */
  qrcodeScan(): Promise<string> {
    return new Promise((resolve) => {
      resolve('');
    });
  }

  /**
   * 分享
   */
  share(arg: ShareArg) {
    emitter.emit('h5-share-panel', {
      data: arg
    })
  }

  /**
   * 微信分享
   */
  wechatShare(arg: ShareItem) {

  }

  /**
   * 打开小程序
   */
  openApplet() {

  }

  /**
   * 收银台
   */
  cashier(arg: PayArg): Promise<string> {
    return new Promise((resolve) => {

      resolve('');
    });
  }

  /**
   * 直播
   */
  liveVideo(id: string) {

  }

  /**
   * toast提示
   * @param msg
   * @param duration
   * @param icon
   */
  toast(msg: string, duration: number, icon: string) {
    console.log('--------> toast');

    promptAction.showToast({
      message: msg,
      duration: 2000
    });
  }

  /**
   * 显示加载框
   */
  showLoading(text: string) {

  }

  /**
   * 隐藏加载框
   */
  hintLoading() {

  }

  /**
   * 录音
   */
  audioRecord(args: AudioArg) {

  }

  /**
   * 媒体播放
   */
  audioPlay(args: PlayArg) {

  }

  /**
   * 页面配置
   */
  headerConfig(arg: PageArg) {

  }

  /**
   * 清除缓存
   */
  clearCache() {

  }

  /**
   * 路由 导航
   */
  navigate(arg: RouteArg) {

  }

  push(arg: RouteArg) {

  }

  /**
   * 路由 返回
   */
  back(de: number) {

  }

  /**
   * 路由 替换
   */
  replace(arg: RouteArg) {

  }

  /**
   * 地图导航
   */
  mapNavigation(arg: NavArg) {
    emitter.emit('h5-navigation-sheet', {
      data: arg
    })
  }

  /**
   * 获取是否
   */
  isDebug(): boolean {
    return false;
  }

  public destroy() {

  }
}