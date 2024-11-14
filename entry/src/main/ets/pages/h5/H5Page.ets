import { webview } from '@kit.ArkWeb';
import { emitter } from '@kit.BasicServicesKit';

import H5Bridge from './bridge/H5Bridge';
import H5Header from './component/H5Header';
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
    emitter.on('web-page', (data: emitter.GenericEventData<string>) => {
      console.log('------->>>', this.ports.length, data.data)
      try {
        const result = '这是需要发送到h5的数据'; // 结果
        const msg = JSON.stringify({ time: Date.now(), key: '', data: result });
        this.ports[1].postMessageEvent(msg);
      } catch (e) {
        console.log('------> catch', e.code, e.message)
      }
    });
  }

  aboutToDisappear(): void {
    this.jsBridge.destroy();
    emitter.off('web-page')
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