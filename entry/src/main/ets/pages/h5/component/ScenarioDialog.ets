/**
 * Author: Meng
 * Date: 2024/11/19
 * Modify: 2024/11/19
 * Desc:
 */
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';

interface ActionArg {
  mode: number;
  data?: Record<string, string>;
}

@Component
export default struct ScenarioDialog {
  @State visible: boolean = false;
  @State mode: number = 1; //
  @State appParam: functionalButtonComponentManager.AppParam = {
    bundleName: 'com.example.test01',
    // abilityName: '阿三大'
  };

  aboutToAppear(): void {
    emitter.on("h5-scenario-panel", (data: emitter.GenericEventData<ActionArg>) => {
      // console.log('scenario --------> ', data);
      const res = data.data||{mode: 0};
      if(res.data) {
        // this.appParam.bundleName = res.bundle;
        // this.appParam.abilityName = res.name;
      }
      this.mode = res.mode;
      this.visible = true;
    });
  }

  aboutToDisappear(): void {
    emitter.off("h5-scenario-panel")
  }

  @Builder
  settingBtn() {

    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.OPEN_SETTING,
        label: '打开设置',
        // 调整Button样式
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .fontSize(16)
            .fontWeight(500)
            .fontColor(Color.White)
            .width('100%')
            .padding({ top: 12, bottom: 12 })
        },
      },
      // OpenType为“OPEN_SETTING”时，回调必须选择“onOpenSetting”
      controller: new functionalButtonComponentManager.FunctionalButtonController().onOpenSetting((err, data) => {
        this.visible = false;
        if (err) {
          console.log(`-------> ${err.code}, ${err.message}`);
          return;
        }
        // 成功日志处理，终止设置应用程序时触发
        hilog.info(0x0000, "testTag", "succeeded in opening setting");
        data.permissions!.forEach((value, key) => {
          hilog.info(0x0000, "testTag", "key: %{public}s value: %{public}s", String(key), value);
        })
      })
    })
  }

  @Builder
  appBtn() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.LAUNCH_APP,
        label: '打开APP',
        appParam: this.appParam,
        // 调整Button样式
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .fontSize(16)
            .fontWeight(500)
            .fontColor(Color.White)
            .width('100%')
            .padding({ top: 12, bottom: 12 })
        },
      },
      // OpenType为“OPEN_SETTING”时，回调必须选择“onOpenSetting”
      controller: new functionalButtonComponentManager.FunctionalButtonController().onLaunchApp((err, data) => {
        this.visible = false;
        if (err) {
          console.log(`-------> ${err.code}, ${err.message}`);
          return;
        }
        // 成功日志处理，终止设置应用程序时触发
        hilog.info(0x0000, "testTag", "succeeded in opening setting");
      })
    })
  }

  build() {
    if (this.visible) {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Column() {
          Text('授权提示')
            .fontSize(20)
            .fontWeight(700)
            .textAlign(TextAlign.Center)
            .textAlign(TextAlign.Center)

          Text('是否打开设置')
            .fontSize(16)
            .margin({ top: 20, bottom: 24 })

          if(this.mode == 0) {
            this.settingBtn()
          }else if(this.mode == 1) {
            this.appBtn()
          }
        }
        .backgroundColor(Color.White)
        .borderRadius(16)
        .width('80%')
        .padding(20)
      }
      .width('100%')
      .height("100%")
      .backgroundColor('rgba(0,0,0,0.5)')
    }
  }
}