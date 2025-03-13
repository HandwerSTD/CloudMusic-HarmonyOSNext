import { PlayList } from "../../common/entities/PlayList"
import { playListClass } from "../../common/entities/PlayList"
import { PlayListPageParam } from "../../common/entities/PageParams"
import Constants from "../../common/constants/Constants"

@Component
export struct PlayListCard {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State isShowHeart: boolean = true
  playList:PlayList = playListClass

  build() {
    Button() {
      Row({ space:15 }) {
        Image(`${this.playList.coverImgUrl}?param=256y256`)
          .width(50)
          .borderRadius(8)
        Column({ space: 8 }) {
          Text(this.playList.name).textStyle(16).fontWeight(FontWeight.Medium)
          Text(`歌单 · ${this.playList.trackCount} 首 · ${this.playList?.creator.nickname}`).textStyle(12)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(60)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .onClick(() => {
      let param: PlayListPageParam = {
        playList: this.playList,
        isShowHeart: this.isShowHeart,
        useTimestamp: true
      }
      if(this.pageInfos.size() < 2) {
        this.pageInfos.pushPathByName('PLayListPage', param, true)
      } else {
        this.pageInfos.replacePathByName('PLayListPage', param, true)
      }
    })
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Component
export struct PlayListCard_Skeleton {
  build() {
    Button() {
      Row({ space:15 }) {
        Column()
          .backgroundColor($r('app.color.main'))
          .width(50)
          .aspectRatio(1)
          .borderRadius(Constants.RADIUS_CARD)
        Column({ space: 8 }) {
          Column().backgroundColor($r('app.color.main')).borderRadius(Constants.RADIUS_CARD).height(Constants.FONT_SIZE_TITLE).width('60%').alignSelf(ItemAlign.Start)
          Column().backgroundColor($r('app.color.main')).borderRadius(Constants.RADIUS_CARD).height(Constants.FONT_SIZE_COMMON).width('40%').alignSelf(ItemAlign.Start)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(Constants.HEIGHT_TEXT_BUTTON)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20, bottom: 10 })
  }
}



