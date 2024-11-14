/**
 * Author: Meng
 * Date: 2024/11/14
 * Modify: 2024/11/14
 * Desc: 访问公共目录中的相册(图片/视频)列表
 */
import { AlbumPickerComponent, AlbumPickerOptions, AlbumInfo, PickerColorMode } from '@kit.MediaLibraryKit';

@Component
export default struct AlbumComponent {
  albumPickerOptions: AlbumPickerOptions = new AlbumPickerOptions();

  aboutToAppear() {
    this.albumPickerOptions.themeColorMode = PickerColorMode.AUTO;

  }

  private onAlbumClick(albumInfo: AlbumInfo): boolean {
    if (albumInfo?.uri) {
      // 通过pickerController向PhotoPickerComponent发送消息，通知其刷新
    }
    if (albumInfo?.albumName) {
      // 基于获取到的albumName后续逻辑处理
    }
    return true;
  }

  build() {
    Stack() {
      AlbumPickerComponent({
        albumPickerOptions: this.albumPickerOptions,
        onAlbumClick: (albumInfo: AlbumInfo) => this.onAlbumClick(albumInfo),
      }).height('100%').width('100%')
    }
  }
}