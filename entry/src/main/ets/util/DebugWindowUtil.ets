/**
 * Author: Meng
 * Date: 2024/11/26
 * Modify: 2024/11/26
 * Desc:
 */
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

let debug_windowClass: window.Window | null = null;
let debugWS: window.WindowStage | null = null;

export function showDebug(ws: window.WindowStage) {
  // 1.创建应用子窗口。
  if (ws == null) {
    console.error('Failed to create the subwindow. Cause: windowStage_ is null');
  } else {
    // debugWS = ws;
    ws.createSubWindow("debugWindow", (err: BusinessError, data) => {
      let errCode: number = err.code;
      if (errCode) {
        console.error('Failed to create the subwindow. Cause: ' + JSON.stringify(err));
        return;
      }
      debug_windowClass = data;
      console.info('Succeeded in creating the subwindow. Data: ' + JSON.stringify(data));
      // 2.子窗口创建成功后，设置子窗口的位置、大小及相关属性等。
      debug_windowClass.moveWindowTo(0, 0, (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          console.error('Failed to move the window. Cause:' + JSON.stringify(err));
          return;
        }
      });
      debug_windowClass.resize(1, 1, (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          console.error('Failed to change the window size. Cause:' + JSON.stringify(err));
          return;
        }
      });
      // 3.为子窗口加载对应的目标页面。
      debug_windowClass.setUIContent("pages/Debug", (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          console.error('Failed to load the content. Cause:' + JSON.stringify(err));
          return;
        }
        // 3.显示子窗口。
        (debug_windowClass as window.Window).showWindow((err: BusinessError) => {
          let errCode: number = err.code;
          if (errCode) {
            console.error('Failed to show the window. Cause: ' + JSON.stringify(err));
            return;
          }
          // 背景色
          data.setWindowBackgroundColor('#00000000');
        });
      });
    })
  }
}

export function resetWindow() {
  if(debugWS) {
    showDebug(debugWS);
  }
}

export function closeDebug(clear: boolean) {
  if (debug_windowClass) {
    (debug_windowClass as window.Window).destroyWindow((err: BusinessError) => {
      let errCode: number = err.code;
      if (errCode) {
        console.error('Failed to destroy the window. Cause: ' + JSON.stringify(err));
        return;
      }
    });
  }
  if(clear) {
    debugWS = null;
  }
}