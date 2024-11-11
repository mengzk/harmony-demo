/**
 * Author: Meng
 * Date: 2024/11/08
 * Modify: 2024/11/08
 * Desc: 分享面板
 */

import { emitter } from "@kit.BasicServicesKit";
import { ShareArg, ShareItem } from "../model/args";

@Component
export default struct SharePanel {
  @State visible: boolean = false;
  @State list: ShareItem[] = [];

  aboutToAppear(): void {
    emitter.on("h5-share-panel", (data: emitter.GenericEventData<ShareArg>) => {
      console.log('share --------> ', data);
      const res = data.data;
      if(res && res.data && res.data.length > 0) {
        this.list = res.data;
        this.visible = true;
      }else {
        console.warn('share --------> 参数不正确或缺少分享类型');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-share-panel');
  }

  onClose() {
    this.visible = false;
  }

  onItemClick(item: ShareItem) {
    this.visible = false;
    console.log('----->', item)
  }

  @Builder
  itemView(item: ShareItem) {
    Column() {
      Text('图标')
      Text('名称').fontColor(Color.Black)
    }
    .height('100%')
    .layoutWeight(1)
    .onClick(this.onItemClick.bind(this, item))
  }

  build() {
    if(this.visible) {
      Flex({ alignItems: ItemAlign.End }) {
        Column() {
          Row() {
            Text('关闭')
              .onClick(this.onClose.bind(this))
            Text('分享')
            Text('关闭')
              .onClick(this.onClose.bind(this))
          }
          .width("100%")
          .margin({ bottom: 48 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row({}) {
            ForEach(this.list, (item: ShareItem) => {
              this.itemView(item)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .width('100%')
        .height(180)
        .padding(16)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height("100%")
      .backgroundColor('rgba(0,0,0,0.5)')
    }
  }
}