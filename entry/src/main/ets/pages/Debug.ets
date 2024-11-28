/**
 * Author: Meng
 * Date: 2024/11/26
 * Modify: 2024/11/26
 * Desc: 测试入口悬浮float
 */
import window from '@ohos.window';
import display from '@ohos.display';
import { emitter } from "@kit.BasicServicesKit";

interface Position { x: number; y: number; }

const boxWidth = vp2px(52);
const boxHeight = vp2px(80);

@Entry
@Component
struct Debug {
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });
  private subWindow: window.Window | null = null;
  private point: Position = { x: 0, y: 0 };
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  @State message: string = 'debug';
  @State curEnv: string = 'test';
  @State isSide: boolean = false;
  @State visible: boolean = true;

  aboutToAppear() {
    this.curEnv = "test";
    const screen = display.getDefaultDisplaySync();
    this.screenWidth = screen.width - boxWidth;
    this.screenHeight = screen.height - boxHeight;
    this.point.x = this.screenWidth;
    // this.point.y = boxHeight;

    this.subWindow = window.findWindow("debugWindow");
    this.subWindow.resize(boxWidth, boxHeight);

    this.onMove();
    this.onMoveEnd();

    emitter.on("app-debug-window", (data: emitter.GenericEventData<boolean>) => {
      // 打开/关闭窗口|更新环境
      this.curEnv = "test";
      if (data.data) {
        this.visible = true;
        this.subWindow?.resize(boxWidth, boxHeight);
      } else {
        this.visible = false;
        this.subWindow?.resize(1, 1);
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off("app-debug-window");
    // 关闭
  }

  // 点击事件
  onItemTap(tag: number) {
    console.log(`-----> debug tap ${tag}`);
    switch (tag) {
      case 1:
        break;
      case 2:
        break;
      default:
        break
    }
  }

  onMoveStart() {
    // 如果在屏幕边缘，恢复
    if (this.subWindow) {
      this.isSide = false;
      this.subWindow.resize(boxWidth, boxHeight);
    }
  }

  onMove() {
    if (this.subWindow == null) {
      console.info('fail in destroying the window.');
    } else {
      let x = Math.min(this.point.x, this.screenWidth);
      let y = Math.min(this.point.y, this.screenHeight);
      x = Math.max(x, 0);
      y = Math.max(y, 50);
      this.subWindow.moveWindowTo(x, y);
    }
  }

  onMoveEnd() {
    // 如果在屏幕边缘，等30秒收起
    if (this.subWindow) {
      const x = this.point.x;
      const w = this.screenWidth - 10;

      if (x >= w) {
        this.isSide = true;
        this.subWindow.resize(boxWidth, boxHeight-80);
      }
    }
  }

  build() {
    if (this.visible) {
      Column() {
        if (this.isSide) {
          Text(this.curEnv)
            .width('100%')
            .fontSize(14)
            .fontWeight(700)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .borderRadius(3)
            .backgroundColor(Color.Red)
            .position({ x: 20, y: 20 })
            .rotate({ x: 0, y: 0, z: 1, angle: 90 })
        } else {
          Text(this.message)
            .width('100%')
            .fontSize(14)
            .lineHeight(20)
            .fontWeight(600)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .borderRadius(3)
            .backgroundColor(Color.Red)
            .onClick(this.onItemTap.bind(this, 1))
          Text(this.curEnv)
            .width('100%')
            .fontSize(14)
            .lineHeight(20)
            .fontWeight(600)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({ top: 10, bottom: 10 })
            .borderRadius(3)
            .backgroundColor(Color.Orange)
            .onClick(this.onItemTap.bind(this, 2))
          Text('GO')
            .width('100%')
            .fontSize(14)
            .lineHeight(20)
            .fontWeight(600)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .borderRadius(3)
            .backgroundColor(Color.Blue)
            .onClick(this.onItemTap.bind(this, 3))
        }
      }
      .width('100%')
      .height("100%")
      // .borderStyle(BorderStyle.Solid)
      // .borderColor(Color.Red)
      // .borderWidth(1)
      .gesture(
        PanGesture(this.panOption)
          .onActionStart(this.onMoveStart.bind(this))
          .onActionUpdate((event: GestureEvent) => {
            this.point.x += event.offsetX;
            this.point.y += event.offsetY;
            this.onMove();
          })
          .onActionEnd(this.onMoveEnd.bind(this))
      )
    }
  }
}