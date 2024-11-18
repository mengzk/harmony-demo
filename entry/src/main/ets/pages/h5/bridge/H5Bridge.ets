/**
 * Author: Meng
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc: h5与原生交互Api
 */
import { router, promptAction } from '@kit.ArkUI';
import { emitter, BusinessError, AsyncCallback } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
import { call, sms } from '@kit.TelephonyKit';
import { picker as filePicker } from '@kit.CoreFileKit';
import { geoLocationManager } from '@kit.LocationKit';
import { sceneMap } from '@kit.MapKit';
import { filePreview } from '@kit.PreviewKit';
// import { pdfViewManager, pdfService } from '@kit.PDFKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';

import { copyFileToCache } from '../utils/File';
import { uploads, upload } from '../utils/axios';
import { Latlng, DeviceDto, UserDto, MediaDto, FileDto, AppDto, UploadDto } from '../model/dtos';
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

export default class H5Bridge {
  methodList: Array<string> = [];
  emitList: Array<string> = [];

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

    emitter.emit(arg.event, {
      data: arg.data
    });
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
      emitter.emit('h5-page', {
        data: data.data
      });
    }
    this.emitList.push(arg.event);
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
    this.emitList = this.emitList.filter(key => key != arg.event);
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
  appInfo(): AppDto {
    return {
      version: '0.0.1'
    }
  }

  /**
   * 打开摄像头 拍照/录像
   */
  openCamera(arg: CameraArg): Promise<UploadDto> {
    let context = getContext(this) as common.Context;
    return new Promise(async (resolve) => {

      let cameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
      let mediaType = [cameraPicker.PickerMediaType.PHOTO];

      if (arg.position == 2) {
        cameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT;
      }

      if (arg.mode == 1) {
        mediaType = [cameraPicker.PickerMediaType.VIDEO];
      } else if (arg.mode == 2) {
        mediaType = [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO];
      }

      try {
        let pickerProfile: cameraPicker.PickerProfile = {
          cameraPosition
        };
        cameraPicker.pick(context, mediaType, pickerProfile)
          .then((result: cameraPicker.PickerResult) => {
            console.log('openCamera result', JSON.stringify(result));
            if (result.resultUri) {
              upload(copyFileToCache(result.resultUri)).then((res) => {
                resolve(res);
              })
            }
          })
          .catch((err: BusinessError) => {
            console.log(`openCamera catch: ${err.code}, ${err.message}`);
            resolve({
              code: -100, msg: '相机打开失败'
            });
          })
      } catch (error) {
        console.error(`openCamera error code: ${error.code}`);
        resolve({
          code: -120, msg: '相机创建失败'
        });
      }
    });
  }

  /**
   * 选择照片
   */
  chooseAlbum(arg: PhotoArg): Promise<UploadDto> {
    // console.log('-----> ', JSON.stringify(arg))
    const photoSelectArgs = new photoAccessHelper.PhotoSelectOptions();
    photoSelectArgs.maxSelectNumber = arg.count || 9; // 选择媒体文件的最大数目
    photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
    if (arg.mode == 1) {
      photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    } else if (arg.mode == 2) {
      photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
    }

    let uris: Array<string> = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();

    return new Promise(resolve => {
      photoViewPicker.select(photoSelectArgs)
        .then((result: photoAccessHelper.PhotoSelectResult) => {
          uris = result.photoUris;
          console.info('choosePhoto succeed:' + uris);
          uploads(uris.map(e => copyFileToCache(e))).then((uRes) => {
            resolve(uRes);
          });
        }).catch((err: BusinessError) => {
        console.error(`choosePhoto failed, code is ${err.code}, message is ${err.message}`);
        resolve({
          msg: 'catch', code: -1
        });
      })
    });
  }

  /**
   * 获取媒体文件
   */
  chooseMedia(arg: MediaArg): Promise<MediaDto> {
    console.log('----->', arg);
    let context = getContext(this) as Context;
    return new Promise(resolve => {
      try {
        let audioSelectOptions = new filePicker.AudioSelectOptions();
        let audioPicker = new filePicker.AudioViewPicker(context);
        audioPicker.select(audioSelectOptions)
          .then((audioSelectResult: Array<string>) => {
            console.info('AudioViewPicker success: ' +
            JSON.stringify(audioSelectResult));
          }).catch((err: BusinessError) => {
          console.error('AudioViewPicker failed: ' + JSON.stringify(err));
        });
      } catch (error) {
        console.error('AudioViewPicker catch: ' + JSON.stringify(error));
      }
    });
  }

  /**
   * 预览图片
   */
  previewImage(arg: PreviewArg) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 预览文档
   */
  previewDocs(arg: PreviewArg) {
    let uiContext = getContext(this);
    let displayInfo: filePreview.DisplayInfo = {
      x: 100,
      y: 100,
      width: 800,
      height: 800
    };
    let fileInfo: filePreview.PreviewInfo = {
      title: '1.txt',
      uri: 'file://docs/storage/Users/currentUser/Documents/1.txt',
      mimeType: 'text/plain'
    };
    filePreview.openPreview(uiContext, fileInfo, displayInfo, (err) => {
      if (err && err.code) {
        console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
        return;
      }
      console.info('Succeeded in opening preview');
    });

    // 多文件预览
    // let files: Array<filePreview.PreviewInfo> = new Array();
    // files.push(fileInfo);
    // filePreview.openPreview(uiContext, files, 0).then(() => {
    //   console.info('Succeeded in opening preview');
    // }).catch((err: BusinessError) => {
    //   console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
    // });
  }

  /**
   * 打开文件夹
   */
  openFolder(arg: FolderArg): Promise<UploadDto> {
    return new Promise((resolve) => {
      try {
        let context = getContext(this) as Context;
        let docSelectOptions = new filePicker.DocumentSelectOptions();
        docSelectOptions.maxSelectNumber = 9;
        docSelectOptions.fileSuffixFilters = ['docx', 'ptx', 'xlsx', 'pdf'];
        let documentPicker = new filePicker.DocumentViewPicker(context);
        documentPicker.select(docSelectOptions, (err: BusinessError, docRes: Array<string>) => {
          console.info('openFolder: ' + JSON.stringify(docRes));
          if (err) {
            console.error('openFolder failed: ' + JSON.stringify(err));
            resolve({
              msg: 'catch', code: 210
            });
          } else {
            uploads(docRes.map(e => copyFileToCache(e))).then((uRes) => {
              resolve(uRes);
            });
          }
        });
      } catch (error) {
        console.error('openFolder catch: ' + JSON.stringify(error));
        resolve({
          msg: 'catch', code: 220
        });
      }
    });
  }

  /**
   * 打开设置
   */
  openSetting(arg: SettingArg) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 打开其他App
   */
  openApp(arg: LinkArg) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 报打电话
   */
  callPhone(phone: string) {
    let context = getContext(this) as Context;
    call.makeCall(context, phone).then(() => {
      console.log(`makeCall success`);
    }).catch((err: BusinessError) => {
      console.error(`makeCall fail, promise: err->${JSON.stringify(err)}`);
    });
  }

  /**
   * 发送短信
   */
  sendSms(phone: string, msg: string) {
    let sendCallback = (err: BusinessError, data: sms.ISendShortMessageCallback) => {
      console.log(`sendSms: err->${JSON.stringify(err)}, data->${JSON.stringify(data)}`);
    };
    let deliveryCallback = (err: BusinessError, data: sms.IDeliveryShortMessageCallback) => {
      console.log(`sendSms: err->${JSON.stringify(err)}, data->${JSON.stringify(data)}`);
    };
    let options: sms.SendMessageOptions = {
      slotId: 0,
      content: msg,
      destinationHost: phone,
      // serviceCenter: '+861xxxxxxxxxx',
      // destinationPort: 1000,
      sendCallback: sendCallback,
      deliveryCallback: deliveryCallback
    };
    sms.sendShortMessage(options, (err: BusinessError) => {
      console.log(`callback: err->${JSON.stringify(err)}`);
    });
  }

  /**
   * 获取位置
   */
  getLocation(arg: LocationArg): Promise<Latlng> {
    return new Promise((resolve) => {
      let requestInfo: geoLocationManager.LocationRequest = {
        'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
        'scenario': geoLocationManager.LocationRequestScenario.UNSET,
        'timeInterval': 1,
        'distanceInterval': 0,
        'maxAccuracy': 0
      };
      let locationChange = (res: geoLocationManager.Location): void => {
        console.log('locationChanger: data: ' + JSON.stringify(res));
        geoLocationManager.off('locationChange', locationChange);
        resolve({
          lat: res.latitude,
          lng: res.longitude,
          altitude: res.altitude,
          accuracy: res.accuracy,
          speed: res.speed,
          code: 0
        })
      };
      try {
        geoLocationManager.on('locationChange', requestInfo, locationChange);
      } catch (err) {
        console.error("errCode:" + JSON.stringify(err)); // 201没权限；3301000位置服务不可用；401参数错误
        resolve({
          lat: 0, lng: 0, code: -1
        })
      }
    });
  }

  chooseAddress(): Promise<Latlng> {
    return new Promise((resolve) => {
      let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
        location: {
          latitude: 39.92194051376904, longitude: 116.3971836796932
        },
        // language: 'zh_CN',
        // 展示搜索控件
        searchEnabled: true,
        // 展示附近Poi
        showNearbyPoi: true
      };
      sceneMap.chooseLocation(getContext(this) as common.UIAbilityContext, locationChoosingOptions)
        .then((data) => {
          console.info("ChooseLocation", "Succeeded in choosing location.");
        })
        .catch((err: BusinessError) => {
          // 1002600003 没权限
          console.error("ChooseLocation", `Failed to choose Location, code: ${err.code}, message: ${err.message}`);
        });

    });
  }

  /**
   * 扫码
   */
  qrcodeScan(): Promise<string> {
    return new Promise((resolve) => {
      let options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true
      };
      try {
        scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
          console.log(`qrcodeScan Succeeded ${JSON.stringify(result)}`);
          resolve(result.originalValue);
        }).catch((error: BusinessError) => {
          console.log(`qrcodeScan Failed to get ScanResult Code: ${error.code}, message: ${error.message}`);
          promptAction.showToast({
            message: error.message
          });
        });
      } catch (error) {
        console.log(`qrcodeScan Failed to startScanForResult. Code: ${error.code}, message: ${error.message}`);
        promptAction.showToast({
          message: '请开启摄像头权限'
        });
      }
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
   * 系统分享
   */
  sysShare(arg: ShareArg) {
    let data: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      content: 'Hello HarmonyOS'
    });

    let controller: systemShare.ShareController = new systemShare.ShareController(data);
    // 获取UIAbility上下文对象
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE
    });
  }

  /**
   * 微信分享
   */
  wechatShare(arg: ShareItem) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 打开小程序
   */
  openApplet() {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 收银台
   */
  cashier(arg: PayArg): Promise<string> {
    promptAction.showToast({
      message: '功能暂不支持'
    });
    return new Promise((resolve) => {
      resolve('');
    });
  }

  /**
   * 直播
   */
  liveVideo(id: string) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * toast提示
   * @param msg
   * @param duration
   * @param icon
   */
  toast(msg: string, duration: number) {
    console.log('--------> toast');
    promptAction.showToast({
      message: msg,
      duration: duration || 2000
    });
  }

  /**
   * 显示加载框
   */
  showLoading(text: string) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 隐藏加载框
   */
  hideLoading() {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 录音
   */
  record(args: AudioArg) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 媒体播放
   */
  mediaPlayer(args: PlayArg) {
    promptAction.showToast({
      message: '功能暂不支持'
    });
  }

  /**
   * 页面配置
   */
  headerConfig(arg: PageArg) {
    emitter.emit('h5-page-title', {
      data: arg
    });
  }

  /**
   * 检查权限
   */
  checkPermission(permissions: string[]) {

  }

  /**
   * 获取权限
   */
  requestPermission(permissions: string[]) {

  }

  /**
   * 获取网络状态
   */
  networkStatus() {

  }

  /**
   * 上传文件
   */
  uploadFiles(files: Array<string>): Promise<UploadDto> {
    return uploads(files.map(e => copyFileToCache(e)));
  }

  /**
   * 删除文件
   */
  deleteFiles(url: string) {

  }

  /**
   * 保存文件
   */
  saveFile(url: string, name?: string, path?: string) {

  }

  /**
   * 读取文件
   */
  readFile(url: string, path?: string) {

  }

  /**
   * 保存数据
   */
  saveItem(key: string, data: object) {

  }

  /**
   * 获取数据
   */
  getItem(key: string) {

  }

  /**
   * 删除数据
   */
  removeItem(key: string) {

  }

  /**
   * 清除缓存
   */
  clearCache() {
    promptAction.showToast({
      message: '清除缓存已清除'
    });
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
   * 路由 导航
   */
  navigate(arg: RouteArg) {
    if (arg.path) {
      router.pushUrl({
        url: arg.path,
        params: arg.params || ''
      })
    } else {
      promptAction.showToast({
        message: '缺少路由路径'
      });
    }
  }

  push(arg: RouteArg) {
    if (arg.path) {
      router.pushUrl({
        url: arg.path,
        params: arg.params || ''
      })
    } else {
      promptAction.showToast({
        message: '缺少路由路径'
      });
    }
  }

  /**
   * 路由 返回
   */
  back(de: number) {
    router.back();
  }

  /**
   * 路由 替换
   */
  replace(arg: RouteArg) {
    if (arg.path) {
      router.replaceUrl({
        url: arg.path,
        params: arg.params || ''
      })
    } else {
      promptAction.showToast({
        message: '缺少路由路径'
      });
    }
  }

  /**
   * 获取是否
   */
  isDebug(): boolean {
    return false;
  }

  public destroy() {
    console.log('destroy ----->', this.emitList);
    if (this.emitList) {
      this.emitList.forEach(key => {
        emitter.off(key);
      })
    }
  }
}