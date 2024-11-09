/**
 * Author: Meng
 * Date: 2024/11/08
 * Modify: 2024/11/08
 * Desc: 地图导航选择面板
 */

import { emitter } from "@kit.BasicServicesKit";
import { NavArg } from "../model/args";

@Component
export default struct NavigationSheet {
  @State visible: boolean = false;
  @State list: string[] = ['高德地图', '百度地图', '腾讯地图'];
  private address?: NavArg;

  aboutToAppear(): void {
    emitter.on("h5-navigation-sheet", (data: emitter.GenericEventData<NavArg>) => {
      console.log('share --------> ', data);
      const res = data.data;
      if(res) {
        this.address = res;
        this.visible = true;
      }else {
        console.warn('share --------> 地址参数不正确');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-navigation-sheet');
  }

  onClose() {
    this.visible = false;
  }

  onItemClick(item: string) {
    this.visible = false;

    console.log('----->', item)
  }

  @Builder
  itemView(tag: string) {
    Row() {
      Text(tag).fontColor(Color.Black)
    }
    .height(48)
    .justifyContent(FlexAlign.Center)
    .onClick(this.onItemClick.bind(this, tag))
  }

  build() {
    if(this.visible) {
      Flex({ alignItems: ItemAlign.End }) {
        Column() {
          ForEach(this.list, (item: string) => {
            this.itemView(item)
          })

          Row() {
            Text('取消').fontColor(Color.Black)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.Center)
          .border({width: { top: 1 }, color: Color.Orange, style: {top: BorderStyle.Solid}})
          .onClick(this.onClose.bind(this))
        }
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height("100%")
      .backgroundColor('rgba(0,0,0,0.5)')
    }
  }
}