import { webview } from '@kit.ArkWeb';

/**
 * H5加载页
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-web-V5
 */

class JSBridge {
  constructor() {
  }

  test(): string {
    console.log('--------> test');
    return "test";
  }

  toast(): void {
    console.log('--------> toast');
  }

  asyncTest(testStr:string): Promise<string> {
    console.log('--------> async Test' + testStr);
    return new Promise(resolve => {
      const date = Date.now();
      setTimeout(() => {
        resolve('结果' + date)
      }, 3000)
    });
  }
}


@Entry
@Component
struct WebPage {
  controller: webview.WebviewController = new webview.WebviewController();
  private localStorage: string =
    "if (typeof(Storage) !== 'undefined') {  localStorage.setItem('color', 'Red'); }";
  @State url: string = 'http://192.168.253.155:8091';
  @State incognito: boolean = true;
  @State scripts: Array<ScriptItem> = [
    { script: this.localStorage, scriptRules: ["*"] }
  ];

  @State jsBridge: JSBridge = new JSBridge();

  aboutToAppear(): void {

  }

  aboutToDisappear(): void {
  }

  onPageShow(): void {
    console.log("-------->")

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
          }
        })
        .javaScriptProxy({
          object: this.jsBridge,
          name: "bnqBridge",
          methodList: ["test", "toast", "asyncTest"],
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