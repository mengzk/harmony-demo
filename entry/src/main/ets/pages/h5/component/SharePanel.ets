/**
 * Author: Meng
 * Date: 2024/11/08
 * Modify: 2024/11/08
 * Desc:
 */

interface ItemDto {

}

@Component
export default struct SharePanel {

  @State list: ItemDto[] = [];

  @Builder
  itemView() {
    Column(){
      Text('图片')
      Text('名称').fontColor(Color.Red)
    }
    .height('100%')
    .layoutWeight(1)
    .onClick(() => {
      console.log('------>')
    })
  }

  build() {
    // Stack({ alignContent: Alignment.Bottom }) {
      Flex({alignItems: ItemAlign.End}){
        Column() {
          Row(){
            Text('关闭')
            Text('分享')
            Text('确认')
          }
          .width("100%")
          .margin({bottom: 48})
          .justifyContent(FlexAlign.SpaceBetween)
          Row({}){
            ForEach([1,2,3], (item:number) => {
              this.itemView()
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .backgroundColor(Color.White)
        .borderRadius({topLeft: 16, topRight: 16})
        .width('100%')
        .height(180)
        .padding(16)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
    .width('100%')
    .height("100%")
    .backgroundColor('rgba(0,0,0,0.5)')
  }
}