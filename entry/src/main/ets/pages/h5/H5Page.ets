import { webview } from '@kit.ArkWeb';
import { emitter } from '@kit.BasicServicesKit';

import H5Bridge from './bridge/H5Bridge';
import H5Header from './component/H5Header';
import SharePanel from './component/SharePanel';
import NavigationSheet from './component/NavigationSheet';
import { EmitDto } from './model/dtos';

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
    "if (typeof(Storage) !== 'undefined') {localStorage.setItem('color', 'Red');}";
  private scripts: Array<ScriptItem> = [{ script: this.localStorage, scriptRules: ["*"] }];
  private jsBridge: H5Bridge = new H5Bridge();
  private jsp: JavaScriptProxy = {
    name: "bnq",
    object: this.jsBridge,
    controller: this.controller,
    methodList: this.jsBridge.methodList,
    // asyncMethodList: ["asyncTest"],
  };
  @State url: string = 'http://192.168.253.109:8091';
  @State progress: number = 0;

  aboutToAppear(): void {
    this.pageEmitHandler();
  }

  aboutToDisappear(): void {
    this.jsBridge.destroy();
    emitter.off('h5-page')
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

    // window.addEventListener("message", (e) => {
    //   console.log("message----->", e);
    //   if (e != null && e.data === "__hmos_port" && e.ports != null) {
    //     h5Port = e.ports[0]; // 1. 保存从应用侧发送过来的端口。
    //     if (h5Port != null) {
    //       h5Port.onmessage = (event) => {
    //         // 2. 接收ets侧发送过来的消息。
    //         const result = event.data;
    //         console.log("h5Port----->", result);
    //       };
    //     }
    //   }
    // });
  }

  pageEmitHandler() {
    emitter.on('h5-page', (data: emitter.GenericEventData<EmitDto>) => {
      console.log('-------> pageEmitHandler', data.data)
      try {
        const msg = JSON.stringify(data);
        this.ports[1].postMessageEvent(msg);
      } catch (e) {
        console.log('------> catch', e.code, e.message)
      }
    });
  }

  gitParams() {

  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        H5Header()
        // 进度条
        if (this.progress < 100) {
          Progress({ value: this.progress, type: ProgressType.Linear })
        }
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
          .javaScriptProxy(this.jsp)
          .onProgressChange((event) => {
            if (event) {
              this.progress = event.newProgress;
            }
          })
          .onTitleReceive((event) => {
            if (event) {
              console.log('title:' + event.title);
            }
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .width("100%")
      }
      .width('100%')
      .height("100%")
      .backgroundColor(Color.White)

      // 分享面板
      SharePanel()
      // 导航面板
      NavigationSheet()
    }
  }
}