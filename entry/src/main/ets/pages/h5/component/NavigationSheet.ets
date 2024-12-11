/**
 * Author: Meng
 * Date: 2024/11/08
 * Modify: 2024/11/08
 * Desc: 地图导航选择面板
 */

import { emitter } from "@kit.BasicServicesKit";
import { NavArg } from "../model/args";

interface MapItem {
  text: string;
  tag: number;
}

@Component
export default struct NavigationSheet {
  @State visible: boolean = false;
  @State list: MapItem[] = [
    { text: '高德地图', tag: 1 },
    { text: '百度地图', tag: 2 },
    { text: '腾讯地图', tag: 3 },
  ];
  private address?: NavArg;

  aboutToAppear(): void {
    emitter.on("h5-navigation-sheet", (data: emitter.GenericEventData<NavArg>) => {
      // console.log('navigation --------> ', data);
      const res = data.data;
      if (res) {
        this.address = res;
        this.visible = true;
      } else {
        console.warn('navigation ---> 导航参数不正确');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-navigation-sheet');
  }

  onClose() {
    this.visible = false;
  }

  onItemClick(tag: number) {
    this.visible = false;
    console.log('----->', tag, this.address);
    if(this.address) {
      // 地址不能为空
      return
    }
    switch (tag) {
      case 1:
        break;
      case 2:
        break;
      default:
        break;
    }
  }

  @Builder
  itemView(item: MapItem) {
    Row() {
      Text(item.text).fontColor(Color.Black)
    }
    .height(48)
    .justifyContent(FlexAlign.Center)
    .onClick(this.onItemClick.bind(this, item.tag))
  }

  build() {
    if (this.visible) {
      Flex({ alignItems: ItemAlign.End }) {
        Column() {
          ForEach(this.list, (item: MapItem) => {
            this.itemView(item)
          })

          Row() {
            Text('取消').fontColor(Color.Black)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.Center)
          .border({ width: { top: 1 }, color: '#e3e3e3', style: { top: BorderStyle.Solid } })
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