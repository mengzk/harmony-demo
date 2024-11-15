/**
 * Author: Meng
 * Date: 2024/11/15
 * Modify: 2024/11/15
 * Desc:
 */
import { common } from '@kit.AbilityKit';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct CustomCamera {
  xController: XComponentController = new XComponentController();

  aboutToAppear(): void {

  }

  getCameraManager(context: common.BaseContext): camera.CameraManager {
    let cameraManager: camera.CameraManager = camera.getCameraManager(context);
    return cameraManager;
  }

  getCameraDevices(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraArray != undefined && cameraArray.length > 0) {
      for (let index = 0; index < cameraArray.length; index++) {
        console.info('cameraId : ' + cameraArray[index].cameraId); // 获取相机ID
        console.info('cameraPosition : ' + cameraArray[index].cameraPosition); // 获取相机位置
        console.info('cameraType : ' + cameraArray[index].cameraType); // 获取相机类型
        console.info('connectionType : ' + cameraArray[index].connectionType); // 获取相机连接类型
      }
      return cameraArray;
    } else {
      console.error("cameraManager.getSupportedCameras error");
      return [];
    }
  }

  onCameraStatusChange(cameraManager: camera.CameraManager): void {
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      if (err !== undefined && err.code !== 0) {
        console.error(`Callback Error, errorCode: ${err.code}`);
        return;
      }
      // 如果当通过USB连接相机设备时，回调函数会返回新的相机出现状态
      if (cameraStatusInfo.status == camera.CameraStatus.CAMERA_STATUS_APPEAR) {
        console.info(`New Camera device appear.`);
      }
      // 如果当断开相机设备USB连接时，回调函数会返回相机被移除状态
      if (cameraStatusInfo.status == camera.CameraStatus.CAMERA_STATUS_DISAPPEAR) {
        console.info(`Camera device has been removed.`);
      }
      // 相机被关闭时，回调函数会返回相机可用状态
      if (cameraStatusInfo.status == camera.CameraStatus.CAMERA_STATUS_AVAILABLE) {
        console.info(`Current Camera is available.`);
      }
      // 相机被打开/占用时，回调函数会返回相机不可用状态
      if (cameraStatusInfo.status == camera.CameraStatus.CAMERA_STATUS_UNAVAILABLE) {
        console.info(`Current Camera has been occupied.`);
      }
      console.info(`camera: ${cameraStatusInfo.camera.cameraId}`);
      console.info(`status: ${cameraStatusInfo.status}`);
    });
  }

  async createInput(cameraDevice: camera.CameraDevice,
    cameraManager: camera.CameraManager): Promise<camera.CameraInput | undefined> {
    // 创建相机输入流
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to createCameraInput errorCode = ' + err.code);
    }
    if (cameraInput === undefined) {
      return undefined;
    }
    // 监听cameraInput错误信息
    cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      console.error(`Camera input error code: ${error.code}`);
    });
    // 打开相机
    await cameraInput.open();
    return cameraInput;
  }

  async getSupportedOutputCapability(cameraDevice: camera.CameraDevice, cameraManager: camera.CameraManager,
    sceneMode: camera.SceneMode): Promise<camera.CameraOutputCapability | undefined> {
    // 获取相机设备支持的输出流能力
    let cameraOutputCapability: camera.CameraOutputCapability =
      cameraManager.getSupportedOutputCapability(cameraDevice, sceneMode);
    if (!cameraOutputCapability) {
      console.error("cameraManager.getSupportedOutputCapability error");
      return undefined;
    }
    console.info("outputCapability: " + JSON.stringify(cameraOutputCapability));
    // 以NORMAL_PHOTO模式为例，需要添加预览流、拍照流
    // previewProfiles属性为获取当前设备支持的预览输出流
    let previewProfilesArray: Array<camera.Profile> = cameraOutputCapability.previewProfiles;
    if (!previewProfilesArray) {
      console.error("createOutput previewProfilesArray == null || undefined");
    }
    //photoProfiles属性为获取当前设备支持的拍照输出流
    let photoProfilesArray: Array<camera.Profile> = cameraOutputCapability.photoProfiles;
    if (!photoProfilesArray) {
      console.error("createOutput photoProfilesArray == null || undefined");
    }
    return cameraOutputCapability;
  }

  getSupportedSceneMode(cameraDevice: camera.CameraDevice,
    cameraManager: camera.CameraManager): Array<camera.SceneMode> {
    // 获取相机设备支持的模式列表
    let sceneModeArray: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraDevice);
    if (sceneModeArray != undefined && sceneModeArray.length > 0) {
      for (let index = 0; index < sceneModeArray.length; index++) {
        console.info('Camera SceneMode : ' + sceneModeArray[index]);
      }
      return sceneModeArray;
    } else {
      console.error("cameraManager.getSupportedSceneModes error");
      return [];
    }
  }

  // 预览输出流
  getPreviewOutput(cameraManager: camera.CameraManager, cameraOC: camera.CameraOutputCapability,
    surfaceId: string): camera.PreviewOutput | undefined {
    let previewProfilesArray: Array<camera.Profile> = cameraOC.previewProfiles;
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfilesArray[0], surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      console.error("Failed to create the PreviewOutput instance. error code: " + err.code);
    }
    return previewOutput;
  }

  // 输出预览流
  async startPreviewOutput(cameraManager: camera.CameraManager, previewOutput: camera.PreviewOutput): Promise<void> {
    let cameraArray: Array<camera.CameraDevice> = [];
    cameraArray = cameraManager.getSupportedCameras();
    if (cameraArray.length == 0) {
      console.error('no camera.');
      return;
    }
    // 获取支持的模式类型
    let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraArray[0]);
    let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
    if (!isSupportPhotoMode) {
      console.error('photo mode not support');
      return;
    }
    let cameraInput: camera.CameraInput | undefined = undefined;
    cameraInput = cameraManager.createCameraInput(cameraArray[0]);
    if (cameraInput === undefined) {
      console.error('cameraInput is undefined');
      return;
    }
    // 打开相机
    await cameraInput.open();
    let session: camera.PhotoSession =
      cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
    session.beginConfig();
    session.addInput(cameraInput);
    session.addOutput(previewOutput);
    await session.commitConfig();
    await session.start();
  }

  // 预览启动结果
  onPreviewOutputFrameStart(previewOutput: camera.PreviewOutput): void {
    previewOutput.on('frameStart', (err: BusinessError) => {
      if (err !== undefined && err.code !== 0) {
        return;
      }
      console.info('Preview frame started');
    });
  }

  // 预览输出错误
  onPreviewOutputError(previewOutput: camera.PreviewOutput): void {
    previewOutput.on('error', (previewOutputError: BusinessError) => {
      console.error(`Preview output error code: ${previewOutputError.code}`);
    });
  }

  build() {
    Column() {
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.xController
      })
        .width(300)
        .height(600)
    }
    .height('100%')
    .width('100%')
  }
}
