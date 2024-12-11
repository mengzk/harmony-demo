/**
 * Author: Meng
 * Date: 2024/11/11
 * Modify: 2024/11/11
 * Desc: 标题栏
 *  { text: '提交', key: 'commit', color: Color.Blue },
 *  { icon: 'share_icon', key: 'share' },
 */
import { emitter } from "@kit.BasicServicesKit";
import { HMRouterMgr } from '@hadss/hmrouter';
import { ActionItem, PageArg } from "../model/args";

@Component
export default struct H5Header {
  back: (() => boolean) | null = null;
  @State title: string = '住小橙';
  @State actions: ActionItem[] = [];
  @State visible: boolean = true;
  @State canBack: boolean = true;

  aboutToAppear(): void {
    emitter.on("h5-page-title", (data: emitter.GenericEventData<PageArg>) => {
      const res = data.data || {};
      console.log('page-title --------> ', JSON.stringify(res));
      if (res) {
        if (res.title) {
          this.title = res.title;
        }
        if (res.actions) {
          this.actions = res.actions;
        }
        if (res.canBack != null) {
          this.canBack = res.canBack;
        }
        this.visible = !(res.hide || false);
      } else {
        console.warn('header config ---> 参数空');
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off('h5-page-title');
  }

  onBack() {
    if (this.back) {
      const isBack = this.back();
      if(!isBack) {
        if (this.canBack) {
          HMRouterMgr.pop()
        }
      }
    }
  }

  onMenuTap(item: ActionItem) {
    emitter.emit('h5-page', {
      data: { key: item.key, tag: item.tag }
    })
  }

  @Builder
  menuView(item: ActionItem, index: number) {
    if (item.text) {
      Text(item.text)
        .fontSize(14)
        .fontWeight(500)
        .fontColor(item.color || Color.Black)
        .padding({ left: index * 8, top: 6, bottom: 6 })
        .onClick(() => this.onMenuTap(item))
    } else if (item.icon) {
      Image($r(`app.media.${item.icon}`))
        .width(32)
        .height(36)
        .padding({ left: index * 8, top: 6, bottom: 6 })
        .onClick(() => this.onMenuTap(item))
    }
  }

  build() {
    if (this.visible) {
      Row() {
        Row() {
          Image($r('app.media.ic_back_arrow_title')).width(10).height(18)
        }
        .width('23%')
        .padding({ left: 16 })
        .onClick(() => this.onBack())

        Text(this.title)
          .fontSize(18)
          .fontWeight(700)
          .width('54%')
          .maxLines(1)
          .textAlign(TextAlign.Center)
          .ellipsisMode(EllipsisMode.END)
        Row() {
          ForEach(this.actions, (e: ActionItem, id: number) => this.menuView(e, id))
        }
        .width('23%')
        .padding({ right: 16 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(46)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}