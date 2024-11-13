/**
 * Author: Meng
 * Date: 2024/11/11
 * Modify: 2024/11/11
 * Desc: 标题栏
 */
import { emitter } from "@kit.BasicServicesKit";
import { PageArg } from "../model/args";

@Component
export default struct H5Header {
  @State title: string = '';
  @State actions: string = '';
  @State visible: boolean = true;

  aboutToAppear(): void {
    emitter.on("h5-page-title", (data: emitter.GenericEventData<PageArg>) => {
      console.log('page --------> ', data);
      const res = data.data;
      if (res) {
        if (res.title) {
          this.title = res.title;
        }
        this.visible = true;
      } else {
        console.warn('share --------> 参数不正确');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-page-title');
  }

  build() {
    if (this.visible) {
      Row() {
        Text("返回")
          .fontColor(Color.Gray)
          .padding({ left: 16, right: 16 })
        Text("测试鸿蒙")
          .fontSize(18)
          .fontWeight(700)
        Text("菜单")
          .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height(46)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)
    }
  }
}