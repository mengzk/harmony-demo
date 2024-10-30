
@Entry
@Component
struct Two {
  @State message: string = '这是第二个页面';

  onPageShow(): void {
    console.log("-------->")
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

        })
    }
    .height('100%')
    .width('100%')
  }
}