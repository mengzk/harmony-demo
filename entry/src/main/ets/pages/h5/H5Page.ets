import { webview } from '@kit.ArkWeb';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { AppUtil } from '@pura/harmony-utils';

import H5Bridge from './bridge/H5Bridge';
import H5Header from './component/H5Header';
import SharePanel from './component/SharePanel';
import NavigationSheet from './component/NavigationSheet';
import { EmitDto } from './model/dtos';
import { Routers } from '../../router/Routers';
import { ActionItem, PageArg } from "./model/args";

/**
 * Author: Meng
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc: h5加载容器
 */

interface ParamOption {
  title?: string;
  hideNav?: boolean;
  supportShare?: boolean;
}

interface MiniProgram {
  appId: string;
  path?: string;
  version?: string;
  downloadUrl?: string;
}

interface H5Params {
  url: string;
  title?: string;
  option?: ParamOption;
  miniProgram?: MiniProgram;
  supportShare?: boolean;
}

// 替换 h5 postMessage 向原生发送消息
const _postMessage = `function bindPostMessage() {
  let hmPort = {postMessage: (arg) => {console.log("---> postMessage unbound", arg);}};
  window.postMessage = (arg) => {
      hmPort.postMessage(arg);
  }
  window.addEventListener("message", (e) => {
    console.log("---> hm port bind", e);
    if (e != null && e.data === "__hmos_port" && e.ports != null) {
      hmPort = e.ports[0];
    }
  });
}
bindPostMessage();
`;

@HMRouter({ pageUrl: Routers.PTCustomWebPage, dialog: false })
@Component
export struct H5Page {
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  // 注入可执行js代码
  private localStorage: string = "if (typeof(Storage) !== 'undefined') {localStorage.setItem('color', 'Red');}";
  // private scripts: Array<ScriptItem> = [{ script: this.localStorage, scriptRules: ["*"] }];
  private jsBridge: H5Bridge = new H5Bridge();
  private jsp: JavaScriptProxy = {
    name: "bnq",
    object: this.jsBridge,
    controller: this.controller,
    methodList: this.jsBridge.methodList,
  };
  private pageParams: H5Params | null = null;
  @State progress: number = 0;
  @State url: string = '';
  @State scripts: Array<ScriptItem> = [{ script: this.localStorage, scriptRules: ["*"] }];

  aboutToAppear(): void {
    this.initPageEmit();
    this.parseParams();
  }

  onBackPress() {
    return this.onBack();
  }

  aboutToDisappear(): void {
    this.jsBridge.destroy();
    emitter.off('h5-page')
    this.clearCache();
  }

  onBack = (): boolean => {
    if (this.controller.accessStep(-1)) {
      this.controller.backward();
      return true;
    } else {
      return false;
    }
  }

  getMessagePorts() {
    // 配置Web开启调试模式
    // webview.WebviewController.setWebDebuggingAccess(true);

    // const custom = this.controller.getCustomUserAgent()
    // const userAgent = this.controller.getUserAgent() + ' baianjuapp_ju/1.0.1';
    // this.controller.setCustomUserAgent(userAgent);
    this.scripts = [{ script: _postMessage, scriptRules: ["*"] }];

    this.ports = this.controller.createWebMessagePorts();
    this.ports[1].onMessageEvent((result) => {
      console.log('-----> onMessageEvent', result);
    });

    this.controller.postMessage('__hmos_port', [this.ports[0]], '*');
  }

  //
  initPageEmit() {
    emitter.on('h5-page', (data: emitter.GenericEventData<EmitDto>) => {
      console.log('-------> initPageEmit', data.data)
      const res: EmitDto = data.data || { key: '' };
      try {
        if (res.key == 'state') {
          // 更新数据
        } else if (res.key == 'reload') {
          this.controller.refresh();
        } else if (res.key == 'clear') {
          this.clearCache();
        } else {
          this.ports[1].postMessageEvent(JSON.stringify(res));
        }
      } catch (e) {
        console.log('------> catch', e.code, e.message)
      }
    });
  }

  // 解析参数
  parseParams() {
    const params = HMRouterMgr.getCurrentParam() as H5Params;
    this.pageParams = params;
    const options: PageArg = {};
    const actions: Array<ActionItem> = [];

    if (params.url) {
      this.url = params.url.trim();
    }
    // 解析参数
    if (params.title) {
      options.title = params.title;
    }
    if (params.supportShare) {
      actions.push({ icon: 'share_icon', key: 'share' });
    }
    if (params.option) {
      const hasShare = actions.some(e => e.key == 'share');
      if (!hasShare && params.option.supportShare) {
        actions.push({ icon: 'share_icon', key: 'share' });
      }
      options.hide = params.option.hideNav;
    }
    // 赋值参数
    options.actions = actions;
    emitter.emit('h5-page-title', { data: options });
    // 小程序 -住小橙没有
    // if(params.miniProgram) {}
  }

  clearCache() {
    try {
      this.controller.clearHistory();
      this.controller.removeCache(true);
    } catch (err) {
      if(err as BusinessError) {
        console.warn(`Web clear err: ${err.code}, ${err.message}`);
      }else {
        console.warn(`Web clear err: ${JSON.stringify(err)}`);
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.normal_bg'))
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      Column() {
        H5Header({ back: this.onBack })
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
          .javaScriptOnDocumentStart(this.scripts)
          .keyboardAvoidMode(WebKeyboardAvoidMode.RESIZE_VISUAL)
          .onPageBegin((event) => {
            if (event) {
              const userAgent = this.controller.getUserAgent() + ' baianjuapp_ju_' + AppUtil.getVersionName();
              this.controller.setCustomUserAgent(userAgent);
            }
          })
          .onPageEnd((event) => {
            if (event) {
              console.log('------> page end: ' + event.url);
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
              // console.log('------> title', event.title);
              emitter.emit('h5-page-title', { data: { title: event.title } });
            }
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .width("100%")
      }
      .width('100%')
      .height("100%")

      // 分享面板
      SharePanel()
      // 导航面板
      NavigationSheet()
    }
  }
}