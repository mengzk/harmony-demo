
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';


  aboutToAppear(): void {
    setTimeout(() => {
      console.log("--------> aboutToAppear")
      this.gotoH5();
    }, 1000)
  }

  onPageShow(): void {
    console.log("-------->")
  }

  gotoH5() {
    router.pushUrl({ url: 'pages/h5/H5Page' }).then(() => {
      console.info('Succeeded in jumping to the second page.')
    }).catch((err: BusinessError) => {
      console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
    })
  }


  build() {
    Column() {
      Text(this.message)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          console.log('======>')
          this.gotoH5();
        })

      Text("好好睡")
    }
    .height('100%')
    .width('100%')
  }
}