/**
 * Author: Meng
 * Date: 2024/11/08
 * Modify: 2024/11/08
 * Desc: 分享面板
 * 10链接；20图片；30微信；40小程序；50企业微信；60飞书
 */

import { emitter, pasteboard } from "@kit.BasicServicesKit";
import { promptAction } from '@kit.ArkUI';

import { ShareArg, ShareItem } from "../model/args";

@Component
export default struct SharePanel {
  @State visible: boolean = false;
  @State list: ShareItem[] = [];

  aboutToAppear(): void {
    emitter.on("h5-share-panel", (data: emitter.GenericEventData<ShareArg>) => {
      // console.log('share --------> ', data);
      const res = data.data;
      if (res && res.data && res.data.length > 0) {
        this.list = res.data.map(e => {
          e.itemName = this.getName(e.channel);
          e.itemIcon = this.getIcon(e.channel);
          return e;
        });
        this.visible = true;
        // animateTo({ duration: 3000 }, () => {});
      } else {
        console.log('-----> share', JSON.stringify(res));
        console.warn('share ---> 参数不正确或缺少分享类型');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-share-panel');
  }

  onClose() {
    this.visible = false;
  }

  copyText(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    promptAction.showToast({ message: '复制成功' });
    // systemPasteboard.getData().then((data) => {});
  }

  onItemClick(item: ShareItem) {
    this.visible = false;
    console.log('----->', JSON.stringify(item));
    switch (item.channel) {
      case 20:
        break;
      case 30:
        break;
      case 40:
        break;
      case 50:
        break;
      case 60:
        break;
      default:
        this.copyText(item.link || '');
        break;
    }
  }

  // 10链接；20图片；30微信；40小程序；50企业微信；60飞书
  getIcon(tag: number): string {
    switch (tag) {
      case 10:
        return 'share_link';
      case 20:
        return 'share_save';
      case 30:
        return 'share_wechat';
      case 40:
        return 'share_wechat';
      case 50:
        return 'share_wwechat';
      case 60:
        return 'share_feishu';
      default:
        return 'share_link';
    }
  }

  getName(tag: number): string {
    switch (tag) {
      case 10:
        return '复制链接';
      case 20:
        return '保存图片';
      case 30:
        return '微信分享';
      case 40:
        return '微信小程序';
      case 50:
        return '企业微信';
      case 60:
        return '飞书';
      default:
        return '复制';
    }
  }

  @Builder
  itemView(item: ShareItem) {
    Column() {
      Image($r(`app.media.${item.itemIcon}`)).width(46).height(46)
      Text(item.itemName).fontColor(Color.Black).fontSize(14).margin({ top: 8 })
    }
    .justifyContent(FlexAlign.Center)
    .onClick(this.onItemClick.bind(this, item))
  }

  build() {
    if (this.visible) {
      Flex({ alignItems: ItemAlign.End }) {
        Column() {
          Text('分享')
            .width('100%')
            .fontColor(Color.Black)
            .fontSize(18)
            .fontWeight(600)
            .textAlign(TextAlign.Center)
            .padding({ top: 18, bottom: 16 })
            .border({ width: { bottom: 1 }, color: '#e3e3e3', style: { top: BorderStyle.Solid } })

          Row() {
            ForEach(this.list, (item: ShareItem) => {
              this.itemView(item)
            })
          }
          .width("100%")
          .layoutWeight(1)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width('100%')
        .height(200)
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height("100%")
      .backgroundColor('rgba(0,0,0,0.5)')
      .transition({ type: TransitionType.Insert, translate: { x: 0, y: 1000 } })
      .onClick(() => this.visible = false)
    }
  }
}