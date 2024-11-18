/**
 * Author: Meng
 * Date: 2024/11/11
 * Modify: 2024/11/11
 * Desc: 标题栏
 */
import { router } from '@kit.ArkUI';
import { emitter } from "@kit.BasicServicesKit";
import { ActionItem, PageArg } from "../model/args";

@Component
export default struct H5Header {
  @State title: string = '住小橙';
  @State actions: ActionItem[] = [
    { text: '提交', key: 'commit', color: Color.Red },
    { text: '菜单', key: 'menu', color: Color.Orange },
  ];
  @State visible: boolean = true;

  aboutToAppear(): void {
    emitter.on("h5-page-title", (data: emitter.GenericEventData<PageArg>) => {
      const res = data.data;
      console.log('page --------> ', JSON.stringify(res));
      if (res) {
        if (res.title) {
          this.title = res.title;
        }
        if (res.actions) {
          this.actions = res.actions;
        }
        this.visible = !(res.hide||false);
      } else {
        console.warn('header config ---> 参数空');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-page-title');
  }

  @Builder
  menuView(item: ActionItem, index: number) {
    if (item.text) {
      Text(item.text)
        .fontSize(14)
        .fontColor(item.color || Color.Black)
        .padding({ left: index * 8, top: 6, bottom: 6 })
        .onClick(() => {
          emitter.emit('h5-title-menu', {
            data: {key: item.key, tag: item.tag}
          })
        })
    }
  }

  build() {
    if (this.visible) {
      Row() {
        Text("返回")
          .width('22%')
          .fontColor(Color.Gray)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            router.back();
          })
        Text(this.title)
          .fontSize(18)
          .fontWeight(700)
          .width('56%')
          .maxLines(1)
          .textAlign(TextAlign.Center)
          .ellipsisMode(EllipsisMode.END)
        Row() {
          ForEach(this.actions, (e: ActionItem, id: number) => this.menuView(e, id))
        }
        .width('22%')
        .padding({ right: 16 })
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(46)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)
    }
  }
}