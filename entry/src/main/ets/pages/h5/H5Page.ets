import { webview } from '@kit.ArkWeb';
import { emitter } from '@kit.BasicServicesKit';

import H5Bridge from './bridge/H5Bridge';
import SharePanel from './component/SharePanel';
import NavigationSheet from './component/NavigationSheet';

/**
 * Author: Meng
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc: h5与原生交互Api
 *
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-web-V5
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/web-app-page-data-channel-V5
 */

@Entry
@Component
struct WebPage {
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  private localStorage: string =
    "if (typeof(Storage) !== 'undefined') {  localStorage.setItem('color', 'Red'); }";
  @State scripts: Array<ScriptItem> = [{ script: this.localStorage, scriptRules: ["*"] }];
  @State jsBridge: H5Bridge = new H5Bridge();
  @State url: string = 'http://192.168.253.155:8091';
  @State progress: number = 0;

  aboutToAppear(): void {

    console.log("-------->aboutToAppear")
    emitter.on("web-page", (data: emitter.GenericEventData<string>) => {
      console.log('>>>>>>>>>>>', this.ports.length, data.data)
      try {
        const result = '这是需要发送到h5的数据'; // 结果
        const msg = JSON.stringify({ time: Date.now(), key: '', data: result });
        this.ports[1].postMessageEvent(msg);

        // 传递runJavaScript侧代码方法。
        // this.controller.runJavaScript('htmlTest(param)');
        // this.controller.runJavaScript(`function changeColor(){document.getElementById('text').style.color = 'red'}`);
      } catch (e) {
        console.log('------> catch', e.code, e.message)
      }
    });
  }

  getMessagePorts() {
    // 配置Web开启调试模式
    // webview.WebviewController.setWebDebuggingAccess(true);

    // const userAgent = this.controller.getUserAgent() + '-hmos';
    // this.controller.setCustomUserAgent(userAgent);

    this.controller.clearHistory();
    this.controller.clearSslCache();

    this.ports = this.controller.createWebMessagePorts();

    this.ports[1].onMessageEvent((result) => {
      console.log('-----> onMessageEvent', result)
    });

    this.controller.postMessage('__hmos_port', [this.ports[0]], '*');
  }

  aboutToDisappear(): void {
    this.jsBridge.destroy();
  }

  onPageShow(): void {

  }

  build() {
    Stack({ alignContent: Alignment.Top }) {

      Web({ src: this.url, controller: this.controller })
        .domStorageAccess(true)
        .fileAccess(true)
        .javaScriptAccess(true)
        .mixedMode(MixedMode.All)
        .zoomAccess(false)
        .databaseAccess(true)
        .geolocationAccess(true)
        .cacheMode(CacheMode.None)
        .copyOptions(CopyOptions.None)
        .webStandardFont("sans-serif")
        .javaScriptOnDocumentStart(this.scripts)
        .keyboardAvoidMode(WebKeyboardAvoidMode.RESIZE_VISUAL)
        .onPageBegin((event) => {
          if (event) {
            console.log('begin url:' + event.url);
          }
        })
        .onPageEnd((event) => {
          if (event) {
            console.log('end url:' + event.url);
            this.getMessagePorts();
          }
        })
        .javaScriptProxy({
          object: this.jsBridge,
          name: "bnq",
          methodList: this.jsBridge.methodList,
          // asyncMethodList: ["asyncTest"],
          controller: this.controller,
        })
        .onProgressChange((event) => {
          if (event) {
            console.log('newProgress:' + event.newProgress);
            this.progress = event.newProgress;
          }
        })
        .onTitleReceive((event) => {
          if (event) {
            console.log('title:' + event.title);
          }
        })
        .expandSafeArea([SafeAreaType.SYSTEM],
          [SafeAreaEdge.BOTTOM])// .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .width("100%")
        .height("100%")
        .backgroundColor(Color.White)

      if (this.progress < 100) {
        Progress({ value: this.progress, type: ProgressType.Linear })
      }

      SharePanel()
      NavigationSheet()
    }
  }
}