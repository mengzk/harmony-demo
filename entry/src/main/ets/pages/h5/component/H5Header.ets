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
      if(res) {
        if(res.title) {
          this.title = res.title;
        }
        this.visible = true;
      }else {
        console.warn('share --------> 参数不正确');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-page-title');
  }

  build() {
    if(this.visible) {
      Row(){
        Text("返回")
        Text("标题")
        Text("菜单")
      }
    }
  }
}