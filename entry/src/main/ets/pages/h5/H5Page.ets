import { webview } from '@kit.ArkWeb';
import { emitter } from '@kit.BasicServicesKit';
/**
 * H5加载页
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-web-V5
 */

import JSBridge from './bridge/H5Bridge'


@Entry
@Component
struct WebPage {
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  private localStorage: string =
    "if (typeof(Storage) !== 'undefined') {  localStorage.setItem('color', 'Red'); }";
  @State url: string = 'http://192.168.253.155:8091';
  @State incognito: boolean = true;
  @State scripts: Array<ScriptItem> = [
    { script: this.localStorage, scriptRules: ["*"] }
  ];
  @State jsBridge: JSBridge = new JSBridge();

  aboutToAppear(): void {
    console.log("-------->aboutToAppear")
    emitter.on("web-page", (data: emitter.GenericEventData<string>) => {
      console.log('>>>>>>>>>>>', this.ports.length, data.data)
      try {
        this.ports[1].postMessageEvent("123456-30953410231231=1-231");
        // const msg: webview.WebMessageExt = new webview.WebMessageExt();
        // msg.setType(1)
        // msg.setString("1234567890-0765432")
        // this.ports[0].postMessageEventExt(msg);
      } catch (e) {
        console.log('------> catch', e.code, e.message)
      }
    });
  }

  aboutToDisappear(): void {
  }

  onPageShow(): void {

  }

  build() {
    Column() {
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
            this.ports = this.controller.createWebMessagePorts();
            this.controller.postMessage('__init_port__', [this.ports[0]], '*');
            // this.ports[1].postMessageEvent("post message from ets to html5");
          }
        })
        .javaScriptProxy({
          object: this.jsBridge,
          name: "bnqBridge",
          methodList: this.jsBridge.methodList,
          // asyncMethodList: ["asyncTest"],
          controller: this.controller,
        })
        .onProgressChange((event) => {
          if (event) {
            console.log('newProgress:' + event.newProgress);
          }
        })
        .onTitleReceive((event) => {
          if (event) {
            console.log('title:' + event.title);
          }
        })
    }
    .width("100%")
    .height("100%")
    .backgroundColor(Color.White)
  }
}