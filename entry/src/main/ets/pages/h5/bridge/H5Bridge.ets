/**
 * Author: Meng
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc: h5与原生交互Api
 */

import display from '@ohos.display';
import { promptAction } from '@kit.ArkUI';
import { deviceInfo, emitter, BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { common, Permissions, bundleManager, OpenLinkOptions } from '@kit.AbilityKit';
import { call, sms } from '@kit.TelephonyKit';
import { systemShare } from '@kit.ShareKit';
import { preferences } from '@kit.ArkData';
import { connection } from '@kit.NetworkKit';
import { HMRouterMgr, HMRouterPathCallback } from '@hadss/hmrouter';
import { AppUtil } from '@pura/harmony-utils';

import {
  initAudio,
  recorderStart,
  recorderPause,
  recorderStop,
  recorderRelease,
  recorderResume
} from '../../../util/RecorderUtil';
import { formatNum } from '../../../util/CommonUtil';
import { getCurLocation, LatLng } from '../../../util/LocationUtil';
import { audioPlayer, playerAction } from '../../../util/AudioPlayerUtil'
import { playerMediaLive, playerMediaVideo } from '../../../util/MediaVideoutil';
import { getCameraInfo, formatStorage, getCameraCache, startContinuousShooting } from '../../../util/InstaCamareUtil'
import { openSysCamera, chooseSysAlbum, chooseAudioFile, chooseDocument } from '../../../util/PhotoAlbumUtil';
import { applyPermissions, checkPermissions, openSettingPage, LOCATION } from '../../../util/PermissionUtil';
import { openFiles } from '../../../util/PreviewUtil';
import { copyFileToCache, saveFileToDisk, readFileFromDisk, deleteFileFromDisk } from '../../../util/FileUtil';
import { axUploads, axUpload, axDownload } from '../../../module/fileAxios';
import { DeviceDto, UserDto, UploadDto } from '../model/dtos';
import {
  EmitArg,
  CameraArg,
  PhotoArg,
  MediaArg,
  AudioArg,
  PlayArg,
  PreviewArg,
  DocsArg,
  LocationArg,
  LinkArg,
  ShareArg,
  ShareItem,
  PayArg,
  NavArg,
  RouteArg,
  PageArg,
  PhoneArg,
  ToastArg,
  FileArg,
  ReadArg,
  DownArg,
  StorageArg,
} from '../model/args'

export default class H5Bridge {
  methodList: Array<string> = [];
  emitList: Array<string> = [];
  static dataPFS: preferences.Preferences | null = null;

  constructor() {
    this.getMethods(H5Bridge);

    let context = getContext(this) as common.Context;
    preferences.getPreferences(context, 'H5Store', (err: BusinessError, res: preferences.Preferences) => {
      if (err) {
        console.warn("preferences init err " + err.code + ", " + err.message);
        return;
      }
      H5Bridge.dataPFS = res;
    });

    initAudio(context);
  }

  getMethods(obj: ESObject) {
    const filterKey = ['constructor', 'getMethods', 'destroy'];
    let keys = Object.getOwnPropertyNames(obj.prototype);
    keys = keys.filter((key: string) => typeof obj.prototype[key] === 'function' && !filterKey.includes(key));
    this.methodList = keys;
    console.log('------>', keys.join(', '));
  }

  /**
   * ❗️调用方法
   */
  // invoke(name: string, data: object) {}

  /**
   * 发送消息
   */
  emit(arg: EmitArg) {
    console.log('emit --->', JSON.stringify(arg));
    emitter.emit(arg.event, {
      data: arg.data
    });
  }

  /**
   * 添加消息监听
   */
  listener(arg: EmitArg) {
    console.log('listener --->', JSON.stringify(arg));
    const onEvent = (data: emitter.GenericEventData<EmitArg>) => {
      const info = data.data;
      console.log('listener onEvent ------> ', info);
      emitter.emit('h5-page', {
        data: info
      });
    }
    if (arg.once) {
      emitter.once(arg.event, onEvent);
    } else {
      this.emitList.push(arg.event);
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

  getToken(): string {
    return "";
  }

  getSessionToken(no: boolean): string {
    return "";
  }

  /**
   * 退出账号
   */
  logout() {

  }

  /**
   * 登录账号
   */
  login(tag: string): UserDto {
    return {};
  }

  /**
   * 设备信息
   */
  deviceInfo(): DeviceDto {
    const screen = display.getDefaultDisplaySync();
    const version = AppUtil.getVersionCode();
    const versionName = AppUtil.getVersionName();
    const top = AppUtil.getStatusBarHeight();
    const bottom = AppUtil.getNavigationIndicatorHeight();
    return {
      width: screen.width,
      height: screen.height,
      vpWidth: px2vp(screen.width),
      vpHeight: px2vp(screen.height),
      vpBottom: px2vp(bottom),
      vpTop: px2vp(top),
      headerHeight: 48,
      safeTop: top,
      safeBottom: bottom,
      model: deviceInfo.brand,
      deviceName: deviceInfo.marketName,
      systemName: deviceInfo.osFullName,
      os: deviceInfo.majorVersion,
      version: deviceInfo.buildVersion,
      appVersion: version,
      appVersionName: versionName,
      uniqueId: deviceInfo.buildHost,
    };
  }

  /**
   * 获取应用信息
   */
  appInfo(): Object {
    return AppUtil.getBundleInfoSync();
  }

  /**
   * 打开摄像头 拍照/录像
   */
  openCamera(arg: CameraArg): Promise<UploadDto> {
    let context = getContext(this) as common.Context;
    if (arg.content) {
      // 水印照片
      return new Promise((resolve) => {
        HMRouterMgr.push({
          pageUrl: 'BNQCamera', param: {
            upload: true, content: arg.content
          }
        }, {
          onResult: (res) => {
            // console.log('-------> ', JSON.stringify(res.result)); // file://media/Photo/105/IMG_1733297998_093/1733297898674.jpg"
            if (res?.result && typeof res.result == 'string') {
              resolve({
                code: 0, msg: 'ok', data: res.result
              });
            }
          },
        });
      });
    }
    return openSysCamera(context, arg.mode, arg.position)
      .then(res => {
        return axUpload(copyFileToCache(res));
      });
  }

  /**
   * 选择照片
   */
  chooseAlbum(arg: PhotoArg): Promise<UploadDto> {
    // console.log('-----> ', JSON.stringify(arg))
    return chooseSysAlbum(arg.mode || 0, arg.count).then(paths => {
      return axUploads(paths.map(e => copyFileToCache(e)));
    });
  }

  /**
   * 获取媒体文件
   */
  chooseMedia(arg: MediaArg): Promise<UploadDto> {
    // console.log('----->', arg);
    let context = getContext(this) as Context;
    return chooseAudioFile(context).then(paths => {
      return axUploads(paths.map(e => copyFileToCache(e)));
    })
  }

  /**
   * 打开文件夹
   */
  chooseDocs(arg: DocsArg): Promise<UploadDto> {
    let context = getContext(this) as Context;
    return chooseDocument(context, arg.count || 9, arg.fileTypes).then(paths => {
      return axUploads(paths.map(e => copyFileToCache(e)));
    })
  }

  /**
   * 预览图片
   */
  previewAlbum(arg: PreviewArg) {
    console.log(JSON.stringify(arg))
    if (arg.video) {
      if (arg.url) {
        playerMediaVideo(arg.url);
      }
    } else {

    }
    // promptAction.showToast({
    //   message: '功能暂不支持'
    // });
  }

  /**
   * 预览文档
   */
  previewDocs(arg: PreviewArg) {
    let context = getContext(this) as common.UIAbilityContext;
    // applyPermissions(['ohos.permission.READ_WRITE_DOCUMENTS_DIRECTORY'], context).then(() => {
    openFiles(arg.data || [], context);
    // })
  }

  /**
   * 打开设置
   */
  openSetting() {
    let context = getContext(this) as common.UIAbilityContext;
    openSettingPage(context);
  }

  /**
   * 打开其他App
   */
  openLink(arg: LinkArg) {
    try {
      // let link = 'app1Scheme://test.example.com/home';
      let canOpen = bundleManager.canOpenLink(arg.link);
      if (canOpen) {
        let context = getContext(this) as common.UIAbilityContext;
        context.openLink(arg.link, {
          appLinkingOnly: false
        })
          .catch((err: BusinessError) => {
            console.warn(`-------> openLink`, arg.link, JSON.stringify(err));
            promptAction.showToast({
              message: '应用打开失败'
            });
          });
      }
    } catch (err) {
      console.warn(`-------> openApp`, arg.link, JSON.stringify(err));
      promptAction.showToast({
        message: '应用不存在'
      });
    }
  }

  canOpenLink(arg: LinkArg): boolean {
    let canOpen = false;
    try {
      canOpen = bundleManager.canOpenLink(arg.link);
    } catch (err) {
      console.warn(`-------> canOpenLink`, arg.link, JSON.stringify(err));
    }
    return canOpen;
  }

  /**
   * 报打电话
   */
  callPhone(arg: PhoneArg) {
    const mobile = arg.mobile;
    let context = getContext(this) as Context;
    call.makeCall(context, mobile).then(() => {
      console.log(`makeCall success`);
    }).catch((err: BusinessError) => {
      console.error(`makeCall fail, promise: err->${JSON.stringify(err)}`);
    });
  }

  /**
   * 发送短信
   */
  sendSms(arg: PhoneArg) {
    const mobile = arg.mobile;
    const msg = arg.text || '';
    let sendCallback = (err: BusinessError, data: sms.ISendShortMessageCallback) => {
      console.log(`sendSms: err->${JSON.stringify(err)}, data->${JSON.stringify(data)}`);
    };
    let deliveryCallback = (err: BusinessError, data: sms.IDeliveryShortMessageCallback) => {
      console.log(`sendSms: err->${JSON.stringify(err)}, data->${JSON.stringify(data)}`);
    };
    let options: sms.SendMessageOptions = {
      slotId: 0,
      content: msg,
      // serviceCenter: mobile,
      destinationHost: mobile,
      // destinationPort: 1000,
      sendCallback: sendCallback,
      deliveryCallback: deliveryCallback
    };
    // 需要权限
    sms.sendShortMessage(options, (err: BusinessError) => {
      console.log(`callback: err->${JSON.stringify(err)}`);
      if (err.code == 201) {
        promptAction.showToast({
          message: '没有权限'
        });
      }
    });
  }

  /**
   * 获取位置
   */
  getLocation(arg: LocationArg): Promise<LatLng> {
    let context = getContext(this) as common.UIAbilityContext;
    return applyPermissions(LOCATION, context).then(res => {
      const canUse = res.some(e => e == -1);
      if (!canUse) {
        return getCurLocation(context, arg.cache);
      } else {
        return {
          latitude: 0, longitude: 0, code: -1
        };
      }
    });
  }

  chooseAddress(): Promise<LatLng> {
    return new Promise((resolve) => {
    });
  }

  /**
   * 扫码
   */
  qrcodeScan(): Promise<string> {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true
    };
    return scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
      // console.log(`qrcodeScan Succeeded ${JSON.stringify(result)}`);
      return result.originalValue;
    }).catch((error: BusinessError) => {
      console.log(`-----> qrcodeScan err: ${error.code}, ${error.message}`);
      promptAction.showToast({
        message: error.message
      });
      return '';
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
  sysShare(arg: ShareItem) {
    // 1链接；20图片；30微信；40小程序；50企业微信
    switch (arg.channel) {
      case 1:
        break;
      default:
        break;
    }
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
  openApplet(arg: ShareItem) {
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
    // playerMediaLive(id); // 直播的线路
  }

  /**
   * toast提示
   * @param icon
   */
  toast(arg: ToastArg) {
    console.log('--------> toast');
    promptAction.showToast({
      message: arg.msg,
      duration: arg.duration || 2000
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
  record(arg: AudioArg): Promise<string> {
    //
    const uploadAudio = (path: string): Promise<string> => {
      console.log('----> uploadAudio', path);
      return axUpload(path).then((uRes) => {
        console.log('----> axUpload', JSON.stringify(uRes));
        return uRes.data || '';
      }).catch(() => '');
    }

    switch (arg.action) {
      case 'start':
        return recorderStart((ms) => {
          const min = formatNum(Math.floor((ms / 1000) / 60));
          const sco = formatNum(Math.round((ms / 1000) % 60));
          emitter.emit('h5-page', {
            data: {
              key: 'audioRecorder',
              data: {
                time: `${min}:${sco}:00`
              }
            }
          });
        });
      case 'pause':
        recorderPause();
        return Promise.resolve('');
      case 'resume':
        recorderResume();
        return Promise.resolve('');
      case 'stop':
        return recorderStop().then((res) => {
          return (res || '').length > 0 ? uploadAudio(res) : res;
        });
      case 'play':
        audioPlayer(arg.url || '');
        return Promise.resolve('');
      case 'pausePlay':
        playerAction('pause', 0);
        return Promise.resolve('');
      case 'resumePlay':
        playerAction('resume', 0);
        return Promise.resolve('');
      case 'stopPlay':
        playerAction('stop', 0);
        return Promise.resolve('');
      default:
        recorderRelease();
        return Promise.resolve('');
    }
  }

  /**
   * 媒体播放
   */
  audioPlayer(arg: PlayArg) {
    if (arg.url && arg.action) {
      audioPlayer(arg.url);
    } else {
      playerAction(arg.action, arg.time);
    }
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
  checkPermission(permissions: Permissions[]): Promise<Array<number>> {
    return checkPermissions(permissions);
  }

  /**
   * 获取权限
   */
  requestPermission(permissions: Permissions[]): Promise<Array<number>> {
    const context = getContext(this) as common.UIAbilityContext;
    return applyPermissions(permissions, context);
  }

  /**
   * 获取网络状态
   */
  networkStatus(): string {
    let netHandle = connection.getAllNetsSync();
    return netHandle.join(',');
  }

  /**
   * 上传文件
   */
  uploadFile(files: Array<string>): Promise<UploadDto> {
    return axUploads(files);
  }

  /**
   * 下栽文件
   */
  downloadFile(arg: DownArg): Promise<string> {
    if (arg && arg.url && arg.url.length > 0) {
      return axDownload(arg.url);
    }
    return Promise.resolve('');
  }

  /**
   * 删除文件
   */
  deleteFiles(paths: Array<string>) {
    if (paths && paths.length > 0) {
      for (let i = 0; i < paths.length; i++) {
        deleteFileFromDisk(paths[0]);
      }
    }
  }

  /**
   * 保存文件
   */
  saveFile(arg: FileArg) {
    if (!arg.dir) {
      const context = getContext(this);
      arg.dir = context.filesDir;
    }
    saveFileToDisk(arg)
  }

  /**
   * 读取文件
   */
  readFile(arg: ReadArg): Promise<string> {
    return readFileFromDisk(arg);
  }

  /**
   * 保存数据
   */
  setStorage(arg: StorageArg) {
    if (H5Bridge.dataPFS) {
      H5Bridge.dataPFS.putSync(arg.key, arg.data);
    }
  }

  /**
   * 获取数据
   */
  getStorage(key: string): preferences.ValueType | undefined {
    return H5Bridge.dataPFS?.getSync(key, null);
  }

  /**
   * 删除数据
   */
  removeStorage(key: string) {
    if (H5Bridge.dataPFS) {
      H5Bridge.dataPFS.deleteSync(key);
    }
  }

  clearStorage() {
    if (H5Bridge.dataPFS) {
      H5Bridge.dataPFS.clear();
    }
  }

  /**
   * 清除缓存
   */
  clearCache() {
    emitter.emit("h5-page", {data: {key: 'clear' }})
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
      let callback: HMRouterPathCallback = {
        onLost() {
          promptAction.showToast({
            message: '页面导航失败'
          });
        }
      }
      HMRouterMgr.push({
        pageUrl: arg.path, param: arg.params
      }, callback)
    } else {
      promptAction.showToast({
        message: '缺少路由路径'
      });
    }
  }

  push(arg: RouteArg) {
    if (arg.path) {
      let callback: HMRouterPathCallback = {
        onLost() {
          promptAction.showToast({
            message: '页面打开失败'
          });
        }
      }
      HMRouterMgr.push({
        pageUrl: arg.path, param: arg.params
      }, callback)
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
    HMRouterMgr.pop();
  }

  /**
   * 路由 替换
   */
  replace(arg: RouteArg) {
    if (arg.path) {
      let callback: HMRouterPathCallback = {
        onLost() {
          promptAction.showToast({
            message: '页面切换失败'
          });
        }
      }
      HMRouterMgr.replace({
        pageUrl: arg.path, param: arg.params
      }, callback)
    } else {
      promptAction.showToast({
        message: '缺少路由路径'
      });
    }
  }

  /**
   *  h5路由栈 -更新h5是否已经到栈顶
   */
  routeStack(canBack: boolean) {
    emitter.emit("h5-page-title", {
      data: {
        canBack
      }
    })
  }

  /**
   * 重新加载
   */
  reload() {
    emitter.emit("h5-page", {
      data: {
        key: "reload"
      }
    })
  }

  /**
   * 获取连接状态
   */
  getInstaInfo() {
    promptAction.showToast({
      message: '功能在不支持'
    });
  }

  /**
   * 格式化存储
   */
  formatInstaStorage() {
    promptAction.showToast({
      message: '功能在不支持'
    });
  }

  /**
   * 获取缓存
   */
  formatInstaCache() {
    promptAction.showToast({
      message: '功能在不支持'
    });
  }

  /**
   * 开始拍摄
   */
  startInstaShoot() {
    promptAction.showToast({
      message: '功能在不支持'
    });
  }

  /**
   * 获取是否
   */
  isDebug(): boolean {
    return AppUtil.getAppInfoSync().debug;
  }

  public destroy() {
    console.log('destroy ----->', this.emitList);
    if (H5Bridge.dataPFS) {
      H5Bridge.dataPFS = null;
    }
    if (this.emitList && this.emitList.length > 0) {
      try {
        this.emitList.forEach(key => {
          emitter.off(key);
        });
      } catch (err) {
        console.log(err);
      }
    }
    playerAction('stop', 0);
    recorderRelease();
  }
}