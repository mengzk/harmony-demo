/**
 * Author: user
 * Date: 2024/11/04
 * Modify: 2024/11/04
 * Desc:
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