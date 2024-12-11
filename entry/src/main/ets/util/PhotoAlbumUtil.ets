/**
 * Author: Meng
 * Date: 2024/12/03
 * Modify: 2024/12/03
 * Desc:
 */
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { picker as filePicker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';

/**
 * 保存图片到相册
 * @param context
 * @param buffer
 */
export async function savePhotoToAlbum(context: common.Context, buffer: ArrayBuffer, name?: string): Promise<string> {
  let options: photoAccessHelper.CreateOptions = {
    title: name || Date.now().toString()
  };

  let helper = photoAccessHelper.getPhotoAccessHelper(context);
  // onClick触发后5秒内通过createAsset接口创建图片文件，5秒后createAsset权限收回。
  let filePath = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', options);
  // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制
  let file = await fileIo.open(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
  try {
    fileIo.writeSync(file.fd, buffer);
    fileIo.closeSync(file);
    // AlertDialog.show({ message: '已保存至相册!' });
    return filePath;
  } catch (err) {
    console.warn('-----> savePhotoToAlbum error ' + JSON.stringify(err));
    return '';
  }
}

/**
 * 获取相册文件
 * @param context
 * @param name
 * @returns
 */
export async function getPhotoAlbumFile(context: common.Context, name?: string): Promise<fileIo.File> {
  let options: photoAccessHelper.CreateOptions = {
    title: name || Date.now().toString()
  };

  let helper = photoAccessHelper.getPhotoAccessHelper(context);
  // onClick触发后5秒内通过createAsset接口创建图片文件，5秒后createAsset权限收回。
  let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', options);
  // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制
  return fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
}

/**
 * 保存截图到相册文件
 * @param context
 * @param pixel
 */
export async function saveSnapshotToAlbum(context: common.Context, pixel: image.PixelMap, name?: string): Promise<string> {
  const imgPicker = image.createImagePacker();
  return imgPicker.packing(pixel, { format: 'image/png', quality: 50 }).then((buff) => {
    return savePhotoToAlbum(context, buff, name).then((res: string) => {
      pixel.release();
      return res;
    });
  }).catch((err: BusinessError) => {
    console.warn(`-----> saveSnapshotToAlbum error ${err.code}, ${err.message}`);
    return '';
  });
}

/**
 * 打开摄像头 拍照/录像
 * @param mode 0照片；1视频; 2视频或图片
 * @param position 1后置,2前置
 */
export async function openSysCamera(context: common.Context, mode: number = 0, position: number = 1): Promise<string> {
  let cameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;
  let mediaType = [cameraPicker.PickerMediaType.PHOTO];

  if (position == 2) {
    cameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT;
  }

  if (mode == 1) {
    mediaType = [cameraPicker.PickerMediaType.VIDEO];
  } else if (mode == 2) {
    mediaType = [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO];
  }

  try {
    let pickerProfile: cameraPicker.PickerProfile = {
      cameraPosition
    };
    return cameraPicker.pick(context, mediaType, pickerProfile)
      .then((result: cameraPicker.PickerResult) => {
        console.log('openCamera result', JSON.stringify(result));
        return result.resultUri;
      })
      .catch((err: BusinessError) => {
        console.warn(`-----> openCamera catch: ${err.code}, ${err.message}`);
        return ''
      })
  } catch (err) {
    console.warn(`openCamera error code: ${err.code}`);
  }
  return '';
}

/**
 * 选择照片/视频
 * @param mode 0图片；1视频；2视频和图片
 * @param count 最大张数
 */
export async function chooseSysAlbum(mode: number, count: number = 9): Promise<Array<string>> {
  // console.log('-----> ', JSON.stringify(arg))
  const photoSelectArgs = new photoAccessHelper.PhotoSelectOptions();
  photoSelectArgs.maxSelectNumber = count || 9; // 选择媒体文件的最大数目
  photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
  if (mode == 1) {
    photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
  } else if (mode == 2) {
    photoSelectArgs.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
  }

  let uris: Array<string> = [];
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();

  return photoViewPicker.select(photoSelectArgs)
    .then((result: photoAccessHelper.PhotoSelectResult) => {
      uris = result.photoUris;
      return uris;
    }).catch((err: BusinessError) => {
      console.warn(`-----> chooseAlbum err ${err.code}, ${err.message}`);
      return [];
    });
}

/**
 * 获取音频文件
 */
export async function chooseAudioFile(context: common.Context): Promise<Array<string>> {
  // console.log('----->', arg);
  try {
    let audioSelectOptions = new filePicker.AudioSelectOptions();
    let audioPicker = new filePicker.AudioViewPicker(context);
    return audioPicker.select(audioSelectOptions)
      .then((result: Array<string>) => {
        console.info('AudioViewPicker success: ' + JSON.stringify(result));
        return result;
      }).catch((err: BusinessError) => {
        console.warn('-----> AudioViewPicker failed: ' + JSON.stringify(err));
        return [];
      });
  } catch (error) {
    console.warn('-----> AudioViewPicker catch: ' + JSON.stringify(error));
  }
  return [];
}

/**
 * 选择文档/文件
 */
export async function chooseDocument(context: common.Context, count: number = 9,
  types?: Array<string>): Promise<Array<string>> {
  try {
    let docSelectOptions = new filePicker.DocumentSelectOptions();
    docSelectOptions.maxSelectNumber = count;
    docSelectOptions.fileSuffixFilters = types || ['docx', 'ptx', 'xlsx', 'pdf'];
    let documentPicker = new filePicker.DocumentViewPicker(context);
    return documentPicker.select(docSelectOptions).then((res) => {
      return res;
    });
  } catch (error) {
    console.warn('-----> openFolder catch: ' + JSON.stringify(error));
  }
  return [];
}